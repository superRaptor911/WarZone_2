#include <MinimapMaker.h>
#include <string>
using namespace godot;

void MinimapMaker::_register_methods()
{
	register_method("_init", &MinimapMaker::_init);
	register_method("_ready", &MinimapMaker::_ready);
	register_method("generateMinimap", &MinimapMaker::generateMinimap);


}

void MinimapMaker::_ready()
{

}

void MinimapMaker::_init()
{

}

PoolByteArray MinimapMaker::generateMinimap(Vector2 world_size, PoolVector2Array used_cells, int cell_size, Color base_color,Color cell_color)
{
	//bytes per line
	int bpl = world_size.x * cell_size * 3;
	int data_size = bpl * world_size.y * cell_size;
	 _data.resize(data_size);

	uint8_t base_clr[3];
	base_clr[0] = int(255.f * base_color.r);
	base_clr[1] = int(255.f * base_color.g);
	base_clr[2] = int(255.f * base_color.b);
	 
	uint8_t cell_clr[3];
	cell_clr[0] = int(255.f * cell_color.r);
	cell_clr[1] = int(255.f * cell_color.g);
	cell_clr[2] = int(255.f * cell_color.b);

	//setting buffer to base color
	for (int i = 0; i < data_size; i+= 3)
	{
		_data[i] = base_clr[0];
	 	_data[i + 1] = base_clr[1];
	 	_data[i + 2] = base_clr[2];
	}

	int cell_count = used_cells.size();

	for (int i = 0; i < cell_count; i++)
	{
		for (int y = 0; y < cell_size ; y++)
	 	{
	 		int addr = bpl * (used_cells[i].y * cell_size + y) + used_cells[i].x * cell_size * 3;
	 		for (int x = 0; x < cell_size ; x++)
	 		{
				_data[addr] = cell_clr[0];
			 	_data[addr + 1] = cell_clr[1];
			 	_data[addr + 2] = cell_clr[2];

			 	addr += 3;
	 		}
	 	}
	}

	Godot::print(std::to_string(cell_size).c_str());

	return _data;
}
