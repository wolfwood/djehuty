module graphics.pen;

import platform.vars.pen;

import Scaffold = scaffold.graphics;

import core.color;

import graphics.view;

class Pen {

public:

	// Constructor
	this(Color clr) {
		Scaffold.createPen(&_pfvars, clr);
	}

	// Destructor
	~this() {
		Scaffold.destroyPen(&_pfvars);
	}

	// Sets color of a solid brush
	void setColor(Color clr) {
		Scaffold.destroyPen(&_pfvars);
		Scaffold.createPen(&_pfvars, clr);

		// when tied to a locked view, update the brush being used
		if (_view !is null) {
			if (_view._locked) {
				_view._graphics.pen = _view._pen;
			}
		}
	}

private:

	package PenPlatformVars _pfvars;

	// tied to a view?
	package View _view; // will be null if no view is tied with it

}
