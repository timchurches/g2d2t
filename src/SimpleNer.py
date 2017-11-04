#! /usr/bin/env python

"""
Simple Named Entity Recogniser

Trained using a list of multi-token terms
Fed a stream of tokens
Spits out marked up regions in the text.
"""

import Tokeniser


class NerState:
    def __init__(self, token):
        self.token = token
        self.transitions = {}
        self.final_lengths = []

    def has_transition(self, token):
        return self.get_transition(token) is not None

    def get_transition(self, token):
        return self.transitions.get(token)

    def add_transition(self, token):
        assert token not in self.transitions
        new_state = NerState(token)
        self.transitions[token] = new_state
        return new_state

    def mark_final(self, token_length, associated_id):
        self.final_lengths.append((token_length, associated_id))

    def is_final(self):
        return len(self.final_lengths) != 0


class NerTraverser:
    def __init__(self, state, standardise=lambda x: x):
        self.state = state
        self.standardise = standardise
        self.collected_term = []

    def traverse(self, token):
        new_state = self.state.get_transition(self.standardise(token.value))
        if new_state is None:
            return None
        self.collected_term.append(token)
        self.state = new_state
        return self


class SimpleNer:
    def __init__(self, label, standardise=lambda x: x):
        self.label = label
        self.standardise = standardise
        self.start_state = NerState(None)

#   def train(self, terms):
#       """
#       Run through the terms and build the recogniser tree
#       """
#       for term, associated_id in terms:
#           self.train_term(term, associated_id)

    def train_term(self, tokens, associated_id):
        """
        Add a single sequence of tokens to the recogniser
        """
        state = self.start_state
        length = len(tokens)
        while tokens:
            next_token = self.standardise(tokens.pop(0))
            if not state.has_transition(next_token):
                state = state.add_transition(next_token)
            else:
                state = state.get_transition(next_token)
            if len(tokens) == 0:
                state.mark_final(length, associated_id)

    def recognise(self, tokens):
        result = []
        traversers = []
        for token in tokens:
            traversers.append(NerTraverser(self.start_state, standardise=self.standardise))
            traversers = filter(None, [traverser.traverse(token) for traverser in traversers])
            for traverser in traversers:
                if traverser.state.is_final():
                    for length, associated_id in traverser.state.final_lengths:
                        result.append((traverser.collected_term[-length:], associated_id))
        return result


if __name__ == '__main__':
    s = SimpleNer('test')
    s.train_term(['THIS', 'is', 'a', 'test'], 1)
    s.train_term(['simple'], 2)
    s.train_term(['simple', 'test'], 3)
    s.train_term(['test'], 4)
    l = Tokeniser.Lexer()
    l.set_input('this is a TEST but not a SIMPLE test')

    print 'Parsing "%s"' % l.lexdata()
    hits = s.recognise(l.lexer)
    for terms, associated_id in hits:
        s, e = terms[0].lexpos, terms[-1].lexpos+len(terms[-1].value)
        print 'found "%s" (%s) at [%d, %d)' % (l.lexer.lexdata[s:e], associated_id, s, e)
