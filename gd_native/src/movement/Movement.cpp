#include "Movement.h"
#include <Variant.hpp>
#include <Math.hpp>
#include <SceneTree.hpp>
#include <Tween.hpp>
#include <math.h>
#include <string>

using namespace godot;


void Movement::_register_methods() {
    register_method("_process", &Movement::_process);
    register_method("_ready", &Movement::_ready);
    register_method("teleport", &Movement::teleport);
    register_method("Server_processInput", &Movement::Server_processInput, GODOT_METHOD_RPC_MODE_REMOTESYNC);
    register_method("sync_serverOutput", &Movement::sync_serverOutput, GODOT_METHOD_RPC_MODE_REMOTESYNC);
    register_method("Client_teleport", &Movement::Client_teleport, GODOT_METHOD_RPC_MODE_REMOTE);
}

Movement::Movement() {
    history.reserve(60);
    time = 0.f;
}


void Movement::_ready() {
    parent    = static_cast<KinematicBody2D *> (get_parent());
    tween = static_cast<Tween *>(parent->get_node("Tween"));
    is_server = get_tree()->is_network_server();
    is_local  = parent->is_network_master();
}


void Movement::_process(float delta) {
    time += delta;
    if (time <= update_delta)
        return;

    time -= update_delta;
    checkForInput();
}



void Movement::checkForInput() {
    if (is_local) {
        float rotation  = parent->get_rotation();
        Vector2 movement_vector = parent->get("direction");

        // Detect change in inputs
        if (movement_vector.length_squared() > 0 || current_state.rotation != rotation) {		
            input_id        += 1;

            ServerIn input;
            input.input_id     = input_id;
            input.rotation     = rotation;
            input.input_vector = movement_vector;

            Client_processInput(input);
            rpc_id(1, "Server_processInput", input.input_id, input.rotation, input.input_vector);
        }
    }
}


State Movement::getStateFromInput(const ServerIn &input) {
    Vector2 old_position = parent->get_position();
    parent->set_position(current_state.position);

    float speed = parent->get("speed");
    Vector2 velocity = input.input_vector.normalized() * speed * update_delta;
    Ref<KinematicCollision2D> collision = parent->move_and_collide(velocity);
    // Test collision
    if (collision.ptr()) {
        velocity.slide(collision->get_normal());
        Vector2 slide_pos = parent->get_position();
        parent->set_position(slide_pos + velocity);
    }

    State state;
    state.input_id     = input.input_id;
    state.position     = parent->get_position();
    state.rotation     = input.rotation;
    state.input_vector = input.input_vector;

    parent->set_position(old_position);
    return state;
}


State Movement::getStateFromState(const State &state) {
    Vector2 old_position = parent->get_position();
    parent->set_position(current_state.position);
    
    float speed = parent->get("speed");
    Vector2 velocity = state.input_vector.normalized() * speed * update_delta;
    Ref<KinematicCollision2D> collision = parent->move_and_collide(velocity);
    // Test collision
    if (collision.ptr()) {
        velocity.slide(collision->get_normal());
        Vector2 slide_pos = parent->get_position();
        parent->set_position(slide_pos + velocity);
    }

    State new_state;
    new_state.input_id     = state.input_id;
    new_state.position     = parent->get_position();
    new_state.rotation     = state.rotation;
    new_state.input_vector = state.input_vector;

    parent->set_position(old_position);
    return new_state;
}

void Movement::Client_processInput(const ServerIn &input) {
    State state   = getStateFromInput(input);
    current_state = state;
    tween->interpolate_property(parent, "position", parent->get_position(), state.position, update_delta, Tween::TRANS_LINEAR, Tween::EASE_OUT);
    tween->start();

    // Server player don't have to keep history
    if (!is_server) {
        history.push_back(state);
    }
}


// Server side Input data processor
void Movement::Server_processInput(int id, float rotation, Vector2 input_vector) {
    if (!is_server) {
        return;
    }

    if (is_local) {
        // If it's server's Character no need to recompute vectors
        // Sent output to all
        rpc("sync_serverOutput", current_state.input_id, current_state.rotation, current_state.position);
    }
    else {
        ServerIn input;
        input.input_vector = input_vector;
        input.input_id     = id;
        input.rotation     = rotation;
        State state        = getStateFromInput(input);
        current_state = state;
        rpc("sync_serverOutput", state.input_id, state.rotation, state.position);
    }
}


void Movement::sync_serverOutput(int id, float rotation, Vector2 position) {
    State new_state;
    new_state.input_id = id;
    new_state.position = position;
    new_state.rotation = rotation;

    if (is_local && !is_server) {
        checkForErrors(new_state);
    } else {
        current_state = new_state;
        tween->interpolate_property(parent, "position", parent->get_position(), position, update_delta, Tween::TRANS_LINEAR, Tween::EASE_OUT);
        tween->interpolate_property(parent, "rotation", parent->get_rotation(), rotation, update_delta, Tween::TRANS_LINEAR, Tween::EASE_OUT);;
        tween->start();
    }
}

void Movement::checkForErrors(const State &state) {
    if(history.size() == 0) {       // Return if no history
        return;
    }

    if (state.input_id < history[0].input_id) {         // Old packet , ignore it
        return;
    }

    int i = 0;
    for (auto &it : history) {
        if (it.input_id == state.input_id) {
            if((it.position - state.position).length_squared() > Max_error_squared ) {
                correctErrors(i, state);
            }
            break;
        }
        i++;
    }

    // Remove old history
    std::vector<State> _history(history.size() - i - 1);     // Beacause i starts from 0
    _history.reserve(60);
    for(; i < _history.size(); i++) {
        _history[i] = history[i];
    }
    history = _history;
}


void Movement::correctErrors(int from, const State &correct_state) {
    parent->set_position(correct_state.position);
    history[from] = correct_state;      // Set correct state

    // Re-compute remaining states
    for(int i = from + 1; i < history.size(); i++) {
        history[i] = getStateFromState(history[i]);
    }

    current_state = history.back();
    Godot::print("Movement::Correcting Errors!!");
}



void Movement::teleport(const Vector2 pos) {
    if (!is_server) {
        Godot::print("Movement::Only server can teleport player");
        return;
    }

    input_id        += 1;
    State new_state; 
    new_state.input_id = input_id; 
    new_state.position = pos; 
    new_state.rotation = 0; 
    current_state = new_state;

    tween->stop_all();
    parent->set_position(pos);
    rpc("Client_teleport", pos);
}


void Movement::Client_teleport(Vector2 position) {
    input_id        += 1;
    State new_state; 
    new_state.input_id = input_id; 
    new_state.position = position; 
    new_state.rotation = 0; 
    current_state = new_state;
    tween->stop_all();

    parent->set_position(position);
    if (is_local && !is_server) {
        history.push_back(new_state);
    } 
}
