/*
 * console.d
 *
 * This file implements the Console interfaces for the Linux system.
 *
 * Author: Dave Wilkinson
 *
 */

module scaffold.console;

import core.main;
import core.unicode;
import core.definitions;
import core.string;

import platform.unix.common;
import platform.unix.main;

import synch.thread;

import tui.application;
import tui.window;

void ConsoleSetColors(uint fg, uint bg, int bright) {
//	printf("\x1B[%d;%d;%dm", bright, 30 + fg, 40 + bg);
	int idx = fg << 3;
	idx |= bg;

	if (bright) {
		Curses.attron(Curses.A_BOLD);
	}
	else {
		Curses.attroff(Curses.A_BOLD);
	}

	Curses.init_pair(idx, fg, bg);
	Curses.attron(Curses.COLOR_PAIR(idx));
}

import io.console;

//will return the next character pressed
Key consoleGetKey() {
	Key ret;

	ubyte[18] tmp;
	uint count;

	ret.code = Curses.getch();
//	Curses.move(0,0);
//	Console.put("                                                ");
//	Curses.move(0,0);
//	Console.put(ret.code, " ");

	if (ret.code != 0x1B) {
		// Not an escape sequence

		if (ret.code == Curses.KEY_MOUSE || ret.code == Curses.KEY_RESIZE || ret.code == Curses.KEY_EVENT || ret.code >= Curses.KEY_MAX) {
			return ret;
		}

		if (ret.code == 9 || ret.code == 13) {
		}
		// For ctrl+char
		else if (ret.code < 26) {
			ret.ctrl = true;
			ret.code = Key.A + ret.code - 1;
	//Curses.move(1,0);
	//Console.put("                                                ");
	//Curses.move(1,0);
	//Console.put("alt: ", ret.alt, " ctrl: ", ret.ctrl, " shift: ", ret.shift, " code: ", ret.code);
			return ret;
		}
		// For F5-F16:
		else if (ret.code >= 281 && ret.code <= 292) {
			ret.code -= 12;
			ret.shift = true;
		}
		else if (ret.code >= 293 && ret.code <= 304) {
			ret.code -= 24;
			ret.ctrl = true;
		}
		else if (ret.code >= 305 && ret.code <= 316) {
			ret.code -= 36;
			ret.ctrl = true;
			ret.shift = true;
		}
		else if (ret.code >= 317 && ret.code <= 328) {
			ret.code -= 48;
			ret.alt = true;
		}

		consoleTranslateKey(ret);
	//Curses.move(1,0);
	//Console.put("                                                ");
	//Curses.move(1,0);
	//Console.put("alt: ", ret.alt, " ctrl: ", ret.ctrl, " shift: ", ret.shift, " code: ", ret.code);

		return ret;
	}

	// Escape sequence...
	ret.code = Curses.getch();
	//Console.put(ret.code, " ");

	// Get extended commands
	if (ret.code == 0x1B) {
		// ESCAPE ESCAPE -> Escape
		ret.code = Key.Escape;
	}
	else if (ret.code == '[') {
		ret.code = Curses.getch();
	//Console.put(ret.code, " ");
		if (ret.code == '1') {
			ret.code = Curses.getch();
	//Console.put(ret.code, " ");
			if (ret.code == '~') {
				ret.code = Key.Home;
			}
			else if (ret.code == '#') {
				ret.code = Curses.getch();
	//Console.put(ret.code, " ");
				if (ret.code == '~') {
					ret.code = Key.F5;
				}
				else if (ret.code == ';') {
					ret.code = Curses.getch();
	//Console.put(ret.code, " ");
					if (ret.code == '2') {
						ret.shift = true;
						ret.code = Key.F5;
					}
				}
			}
			else if (ret.code == '7') {
				ret.code = Curses.getch();
	//Console.put(ret.code, " ");
				if (ret.code == '~') {
					ret.code = Key.F6;
				}
				else if (ret.code == ';') {
					ret.code = Curses.getch();
	//Console.put(ret.code, " ");
					if (ret.code == '2') {
						ret.shift = true;
						ret.code = Key.F6;
					}
				}
			}
			else if (ret.code == ';') {
				// Arrow Keys
				ret.code = Curses.getch();
	//Console.put(ret.code, " ");
				getModifiers(ret);
	//Console.put(ret.code, " ");

				if (ret.code == 'A') {
					ret.code = Key.Up;
				}
				else if (ret.code == 'B') {
					ret.code = Key.Down;
				}
				else if (ret.code == 'C') {
					ret.code = Key.Right;
				}
				else if (ret.code == 'D') {
					ret.code = Key.Left;
				}
			}
			else {
				ret.code = Curses.getch();
	//Console.put(ret.code, " ");
			}
		}
		else if (ret.code == '2') {
			ret.code = Curses.getch();
	//Console.put(ret.code, " ");
			if (ret.code == '~') {
			}
			else if (ret.code == ';') {
				// Alt + Insert
				ret.code = Curses.getch();
	//Console.put(ret.code, " ");
				getModifiers(ret);
	//Console.put(ret.code, " ");
				if (ret.code == '~') {
					ret.code = Key.Insert;
				}
			}
		}
		else if (ret.code == '3') {
			ret.code = Curses.getch();
	//Console.put(ret.code, " ");
		}
		else if (ret.code == '4') {
			ret.code = Curses.getch();
	//Console.put(ret.code, " ");
		}
		else if (ret.code == '5') {
			ret.code = Curses.getch();
	//Console.put(ret.code, " ");
		}
		else if (ret.code == '6') {
			ret.code = Curses.getch();
	//Console.put(ret.code, " ");
		}
		else {
		}
	}
	else if (ret.code == 'O') {
		ret.code = Curses.getch();

		// F1, F2, F3, F4
		if (ret.code == '1') {
			ret.code = Curses.getch();
	//Console.put(ret.code, " ");
			if (ret.code == ';') {
				ret.code = Curses.getch();
	//Console.put(ret.code, " ");
				getModifiers(ret);
	//Console.put(ret.code, " ");

				if (ret.code == 'P') {
					ret.code = Key.F1;
				}
				else if (ret.code == 'Q') {
					ret.code = Key.F2;
				}
				else if (ret.code == 'R') {
					ret.code = Key.F3;
				}
				else if (ret.code == 'S') {
					ret.code = Key.F4;
				}
			}
		}
		else if (ret.code == 'H') {
			ret.code = Key.Home;
		}
		else if (ret.code == 'F') {
			ret.code = Key.End;
		}
		else if (ret.code == 0x80) {
			ret.code = Key.F1;
		}
		else if (ret.code == 0x81) {
			ret.code = Key.F2;
		}
		else if (ret.code == 0x82) {
			ret.code = Key.F3;
		}
		else if (ret.code == 0x83) {
			ret.code = Key.F4;
		}
	}
	else {
		// Alt + Char
		ret.alt = true;
		consoleTranslateKey(ret);
	}

	//Curses.move(1,0);
	//Console.put("                                                ");
	//Curses.move(1,0);
	//Console.put("alt: ", ret.alt, " ctrl: ", ret.ctrl, " shift: ", ret.shift, " code: ", ret.code);

	return ret;
}

void getModifiers(ref Key key) {
	if (key.code == '2' || key.code == '4' || key.code == '6' || key.code == '8') {
		key.shift = true;
	}

	if (key.code == '3' || key.code == '4' || key.code == '7' || key.code == '8') {
		key.alt = true;
	}

	if (key.code == '5' || key.code == '6' || key.code == '7' || key.code == '8') {
		key.ctrl = true;
	}

	if (key.shift || key.alt || key.ctrl) {
		key.code = Curses.getch();
	}
}

void consoleTranslateKey(ref Key ky)
{
	switch(ky.code) {
		case '~':
		case '!':
		case '@':
		case '#':
		case '$':
		case '%':
		case '^':
		case '&':
		case '*':
		case '(':
		case ')':
		case '_':
		case '+':
		case '{':
		case '}':
		case ':':
		case '"':
		case '<':
		case '>':
		case '|':
		case '?':
			ky.shift = true;
			break;
		default:
			if (ky.code >= 'A' && ky.code <= 'Z') {
				ky.shift = true;
			}
			else if (ky.code >= '0' && ky.code <= '9') {
				ky.shift = true;
			}
			break;
	}
	ky.code = keyTranslation[ky.code];
}

uint keyTranslation[Curses.KEY_MAX] = [
	' ': Key.Space,
	'\n': Key.Return,
	'\r': Key.Return,
	'\t': Key.Tab,
	'a': Key.A,
	'b': Key.B,
	'c': Key.C,
	'd': Key.D,
	'e': Key.E,
	'f': Key.F,
	'g': Key.G,
	'h': Key.H,
	'i': Key.I,
	'j': Key.J,
	'k': Key.K,
	'l': Key.L,
	'm': Key.M,
	'n': Key.N,
	'o': Key.O,
	'p': Key.P,
	'q': Key.Q,
	'r': Key.R,
	's': Key.S,
	't': Key.T,
	'u': Key.U,
	'v': Key.V,
	'w': Key.W,
	'x': Key.X,
	'y': Key.Y,
	'z': Key.Z,
	'A': Key.A,
	'B': Key.B,
	'C': Key.C,
	'D': Key.D,
	'E': Key.E,
	'F': Key.F,
	'G': Key.G,
	'H': Key.H,
	'I': Key.I,
	'J': Key.J,
	'K': Key.K,
	'L': Key.L,
	'M': Key.M,
	'N': Key.N,
	'O': Key.O,
	'P': Key.P,
	'Q': Key.Q,
	'R': Key.R,
	'S': Key.S,
	'T': Key.T,
	'U': Key.U,
	'V': Key.V,
	'W': Key.W,
	'X': Key.X,
	'Y': Key.Y,
	'Z': Key.Z,
	'0': Key.Zero,
	'1': Key.One,
	'2': Key.Two,
	'3': Key.Three,
	'4': Key.Four,
	'5': Key.Five,
	'6': Key.Six,
	'7': Key.Seven,
	'8': Key.Eight,
	'9': Key.Nine,
	'`': Key.SingleQuote,
	'~': Key.SingleQuote,
	'!': Key.One,
	'@': Key.Two,
	'#': Key.Three,
	'$': Key.Four,
	'%': Key.Five,
	'^': Key.Six,
	'&': Key.Seven,
	'*': Key.Eight,
	'(': Key.Nine,
	')': Key.Zero,
	'-': Key.Minus,
	'_': Key.Minus,
	'=': Key.Equals,
	'+': Key.Equals,
	'[': Key.LeftBracket,
	'{': Key.LeftBracket,
	']': Key.RightBracket,
	'}': Key.RightBracket,
	';': Key.Semicolon,
	':': Key.Semicolon,
	'\'': Key.Quote,
	'"': Key.Quote,
	',': Key.Comma,
	'<': Key.Comma,
	'>': Key.Period,
	'.': Key.Period,
	'/': Key.Foreslash,
	'?': Key.Foreslash,
	'\\': Key.Backslash,
	'|': Key.Backslash,
	Curses.KEY_DOWN: Key.Down,
	Curses.KEY_UP: Key.Up,
	Curses.KEY_LEFT: Key.Left,
	Curses.KEY_RIGHT: Key.Right,
	Curses.KEY_HOME: Key.Home,
	Curses.KEY_BACKSPACE: Key.Backspace,
	Curses.KEY_F1: Key.F1,
	Curses.KEY_F2: Key.F2,
	Curses.KEY_F3: Key.F3,
	Curses.KEY_F4: Key.F4,
	Curses.KEY_F5: Key.F5,
	Curses.KEY_F6: Key.F6,
	Curses.KEY_F7: Key.F7,
	Curses.KEY_F8: Key.F8,
	Curses.KEY_F9: Key.F9,
	Curses.KEY_F10: Key.F10,
	Curses.KEY_F11: Key.F11,
	Curses.KEY_F12: Key.F12,
	Curses.KEY_F13: Key.F13,
	Curses.KEY_F14: Key.F14,
	Curses.KEY_F15: Key.F15,
	Curses.KEY_F16: Key.F16,
	Curses.KEY_NPAGE: Key.PageDown,
	Curses.KEY_PPAGE: Key.PageUp,
	Curses.KEY_ENTER: Key.Return,
	Curses.KEY_END: Key.End
];


struct winsize {
	ushort ws_row;
	ushort ws_col;
	ushort ws_xpixel;
	ushort ws_ypixel;
}

//window size

int m_width;
int m_height;

bool m_winsize_state;




const auto TIOCGWINSZ = 0x5413;
const auto SIGWINCH = 28;

//position tracking

int m_x;
int m_y;

winsize m_winsize_saved;
winsize m_winsize_working;

termios m_term_info_saved;
termios m_term_info_working;



//signal handler for terminal Size

extern(C) void close_sig_handler(int signal) {
	Djehuty.end(0);
//	for(int i=0; i<256; i++) {
//		printf("\x1B[48;5;%dma", i);
//	}
	ConsoleUninit();
	exit(0);
}

extern(C) void size_sig_handler(int signal) {

    ioctl(STDIN, TIOCGWINSZ, &m_winsize_working);

    if (m_width != m_winsize_working.ws_col || m_height != m_winsize_working.ws_row) {
        m_width = m_winsize_working.ws_col;
        m_height = m_winsize_working.ws_row;

        while (m_x >= m_width)
        {
            m_y++;
            m_x -= m_width;
        }

        if (m_y >= m_height) { m_y = m_height-1; }
        if (m_x < 0) { m_x = 0; }
        if (m_y < 0) { m_y = 0; }

        //reset (this will be retained when program exits)
        m_winsize_saved = m_winsize_working;

        //the window resized through the users actions, not through the class' resize()
        //therefore don't change it back to anything on exit
        m_winsize_state = false;
    }

    //fire Size event
	TuiApplication app = cast(TuiApplication)Djehuty.app;
	app.window.onResize();
}

void ConsoleInit()
{
	setlocale(LC_ALL, "");
	setlocale(LC_CTYPE, "");
    //direct the Size signal to the internal function
//    signal(SIGWINCH, &size_sig_handler);
//	signal(SIGINT, &close_sig_handler);
	//sigset(SIGKILL, &close_sig_handler);
	//sigset(SIGTERM, &close_sig_handler);

	// set buffer to print without newline
	setvbuf (stdout, null, _IONBF, 0);

	Curses.initscr();
	setlocale(LC_ALL, "");
	setlocale(LC_CTYPE, "");
	Curses.start_color();
	Curses.keypad(Curses.stdscr, 1);

	Curses.move(0,0);

	Curses.nonl();
	Curses.cbreak();
	Curses.noecho();

	Curses.raw();

	Curses.mmask_t oldmask;
	Curses.mousemask(Curses.ALL_MOUSE_EVENTS | Curses.REPORT_MOUSE_POSITION, &oldmask);
	Curses.mouseinterval(0);

	// Get current position
	m_x = 0;
	m_y = 0;

	Curses.getmaxyx(Curses.stdscr, m_height, m_width);

	setlocale(LC_ALL, "");
	setlocale(LC_CTYPE, "");
}

void ConsoleUninit() {
	Curses.endwin();
}

void ConsoleClear() {
//	printf("\x1B[2J\x1B[0;0H");
	Curses.clear();
	Curses.refresh();
}

void ConsoleSetRelative(int x, int y) {
	int newx;
	int newy;

	Curses.getyx(Curses.stdscr, m_y, m_x);

	newx = m_x + x;
	newy = m_y + y;

	Curses.move(m_y, m_x);
}

uint[] ConsoleGetPosition() {
	Curses.getyx(Curses.stdscr, m_y, m_x);
	return [m_x, m_y];
}

void ConsoleSetPosition(uint x, uint y) {
    if (x >= m_width) { x = m_width-1; }

    if (y >= m_height) { y = m_height-1; }

    if (x < 0) { x = 0; }

    if (y < 0) { y = 0; }

	Curses.move(y,x);
}

void ConsoleHideCaret() {
//	printf("\x1B[?25l");
	Curses.curs_set(0);
}

void ConsoleShowCaret() {
//	printf("\x1B[?25h");
	Curses.curs_set(1);
}

void ConsoleSetHome() {
//	printf("\x1B[0G");
	Curses.getyx(Curses.stdscr, m_y, m_x);
	m_x = 0;
	Curses.move(m_y, m_x);
}

void ConsolePutString(dchar[] chrs) {
	chrs ~= '\0';
	char[] utf8 = Unicode.toUtf8(chrs);
//	printf("%s", utf8.ptr);
	Curses.wprintw(Curses.stdscr, "%s", utf8.ptr);
	Curses.refresh();
}

void ConsolePutChar(dchar chr) {
	dchar[] chrarray = [ chr, '\0' ];
	char[] chrs = Unicode.toUtf8(chrarray);

//	printf("%s", chrs.ptr);
	Curses.wprintw(Curses.stdscr, "%s", chrs.ptr);
	Curses.refresh();
}

void ConsoleGetSize(out uint width, out uint height) {
	Curses.getmaxyx(Curses.stdscr, m_height, m_width);

	width = m_width;
	height = m_height;
}

void ConsoleGetChar(out dchar chr, out uint code) {
}