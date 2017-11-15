import spacy
from spacy.matcher import Matcher

nlp = spacy.load('en')
matcher = Matcher(nlp.vocab)

# Get the ID of the 'EVENT' entity type. This is required to set an entity.
EVENT = nlp.vocab.strings['EVENT']

print(EVENT)

def add_event_ent(matcher, doc, i, matches):
    # Get the current match and create tuple of entity label, start and end.
    # Append entity to the doc's entity. (Don't overwrite doc.ents!)
    match_id, start, end = matches[i]
    doc.ents += ((EVENT, start, end),)

matcher.add('GoogleIO', add_event_ent,
            [{'ORTH': 'Google'}, {'UPPER': 'IO'}])
            
doc = nlp(u"I am planning to go to Google IO 2017 this year or next year.")

matches = matcher(doc)
print(doc)
print(matches)


for token in doc:
    print(token.text, token.lemma_, token.pos_, token.tag_, token.dep_,
          token.shape_, token.is_alpha, token.is_stop, token.ent_type_)

print(doc.ents)

ents = [(e.text, e.start_char, e.end_char, e.label_) for e in doc.ents]

print(ents)
