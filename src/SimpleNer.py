#! /usr/bin/env python

"""
Simple Named Entity Recogniser

Trained using a list of multi-token terms
Fed a stream of tokens
Spits out marked up regions in the text.
"""


class NerState:
    def __init__(self, token, final_state=False):
        self.token = token
        self.transitions = {}
        self.final_state = final_state

    def has_transition(self, token):
        return self.get_transition(token) is not None

    def get_transition(self, token):
        return self.transitions.get(token)

    def add_transition(self, token):
        assert token not in self.transitions
        new_state = NerState(token)
        self.transitions[token] = new_state
        return new_state

    def mark_final(self):
        self.final_state = True

    def is_final(self):
        return self.final_state


class NerTraverser:
    def __init__(self, state):
        self.state = state
        self.collected_term = []

    def traverse(self, token):
        new_state = self.state.get_transition(token)
        if new_state is None:
            return None
        self.collected_term.append(token)
        self.state = new_state
        return self


class SimpleNer:
    def __init__(self, edit_tolerance=0):
        self.edit_tolerance = edit_tolerance
        self.start_state = NerState(None)

    def train(self, terms):
        """
        Run through the terms and build the recogniser tree
        """
        for term in terms:
            self.train_term(term)

    def train_term(self, tokens):
        """
        Add a single sequence of tokens to the recogniser
        """
        state = self.start_state
        while tokens:
            next_token = tokens.pop(0)
            if not state.has_transition(next_token):
                state = state.add_transition(next_token)
            else:
                state = state.get_transition(next_token)
            if len(tokens) == 0:
                state.mark_final()

    def recognise(self, tokens):
        traversers = []
        for token in tokens:
            traversers.append(NerTraverser(self.start_state))
            traversers = filter(None, [traverser.traverse(token) for traverser in traversers])
            for traverser in traversers:
                if traverser.state.is_final():
                    print traverser.collected_term


if __name__ == '__main__':
    s = SimpleNer()
    s.train([['this', 'is', 'a', 'test'], ['simple'], ['simple', 'test'], ['test']])
    s.recognise('this is a test but not a simple test'.split())
