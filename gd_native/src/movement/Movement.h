#ifndef CHARMOVEMENT_H
#define CHARMOVEMENT_H

#include <Godot.hpp>
#include <KinematicBody2D.hpp>
#include <Input.hpp>
#include <vector>
#include <Reference.hpp>
#include <KinematicCollision2D.hpp>
#include <CollisionShape2D.hpp>
#include <Tween.hpp>

template<class T>
T lerp(const T &minv, const T &maxv, float t) {
	return minv + t * (maxv - minv);
}

namespace godot {
    struct ServerIn {
        int input_id                = 0;
        float rotation              = 0.f;
        Vector2 input_vector        = Vector2(0,0);
    };

    struct State {
        int input_id                = 0;
        float rotation              = 0.f;
        Vector2 input_vector        = Vector2(0,0);
        Vector2 position            = Vector2(0,0);
    };


    class Movement : public Node {
        GODOT_CLASS(Movement, Node)
        private:
            KinematicBody2D *parent;

            int   input_id            = 0;
            float update_delta        = 1.f / 25.f;
            float time                = 0.f;
            State current_state;
            std::vector<State> history;

            bool is_server = false;
            bool is_local  = false;

            const float Max_error_squared = 4;

        private:

            void checkForInput();

            State getStateFromInput(const ServerIn &input);
            State getStateFromState(const State &state);
            void Client_processInput(const ServerIn &input);
            void Server_processInput(int id, float rotation, Vector2 input_vector);
            void sync_serverOutput(int id, float rotation, Vector2 position);

            void checkForErrors(const State &state);
            void correctErrors(int from, const State &correct_state);
            void teleportCharacter(const Vector2 pos);

        public:
            static void _register_methods();

            Movement();
            ~Movement(){};

            void _init() {}; // our initializer called by Godot
            void _ready();
            void _process(float delta);
    };
}

#endif
