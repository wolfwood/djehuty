/*
 * expressionunit.d
 *
 * This module parses expressions.
 *
 */

module parsing.d.aggregatebodyunit;

import parsing.parseunit;
import parsing.token;

import parsing.d.tokens;
import parsing.d.nodes;

import parsing.d.declarationunit;

import io.console;

import djehuty;

class AggregateBodyUnit : ParseUnit {
	override bool tokenFound(Token current) {
		switch (current.type) {
			// We are always looking for the end of the body.
			case DToken.RightCurly:
				// Done.
				return false;

			// A new keyword will set up an allocator.
			case DToken.New:
				// TODO:
				break;

			// Ditto for a delete token for deallocator.
			case DToken.Delete:
				// TODO:
				break;

			// Otherwise, it must be some Declarator
			default:
				lexer.push(current);
				auto tree = expand!(DeclarationUnit)();
				break;
		}
		return true;
	}

protected:
	string cur_string = "";

	static const string _common_error_msg = "";
	static const string[] _common_error_usages = null;
}
