import feather
import pandas as pd
import os, sys, csv

from spacy.lang.en import English
from spacy.matcher import Matcher
from spacy.tokens import Doc, Span, Token
from spacy import displacy
import spacy

drug_names_path = "data/drug_names.feather"
drug_names_df = feather.read_dataframe(drug_names_path)
a = drug_names_df['drug_id'].tolist()
b = drug_names_df['term'].tolist()
drug_names_list = [(a[i], b[i]) for i in range(len(a))]

with open('src/drugbank_stoplist.txt') as f:
    drug_names_stop_list = [w.lower() for w in f.read().splitlines()]

interventions_path = "data/interventions.feather"
interventions_df = feather.read_dataframe(interventions_path)
a = interventions_df['trial_number'].tolist()
b = interventions_df['interventions'].tolist()
interventions_list = [(a[i], b[i]) for i in range(len(a))]

# Use the standard en pipeline
nlp = spacy.load('en')

class DrugBankMatcher():

    def __init__(self, nlp=None, drugs=list()):
        self.nlp = nlp
        self.drugs = drugs
        self.matcher = Matcher(self.nlp.vocab)
        self.num_drugs = len(self.drugs)
        self.i = -1

    def __iter__(self):
        return self

    def __next__(self):
        if self.i < self.num_drugs:
            i = self.i + 1
            self.i = i
            drug_id, drug_term = self.drugs[i]
            if drug_term is not None:
                pattern_dict_list = []
                drug_doc = self.nlp(drug_term)
                for tok in drug_doc:
                    if tok.is_punct:
                        pattern_dict_list.append({'OP': '*', 'IS_PUNCT': True})
                    else: 
                        pattern_dict_list.append({'LOWER': tok.lower})
                label = drug_id
                if len(pattern_dict_list) > 0:
                    self.matcher.add(label, None, pattern_dict_list)
            return i
        else:
            raise StopIteration()

    def __call__(self, doc):
        """Apply the pipeline component on a Doc object and modify it if matches
        are found. Return the Doc, so it can be processed by the next component
        in the pipeline, if available.
        """
        matches = self.matcher(doc)
        
        spans = []  # keep the spans for later so we can merge them afterwards
        for _, start, end in matches:
            # print(self.vocab[_].text, start, end)
            # Generate Span representing the entity & set label
            entity = Span(doc, start, end, label=self.vocab[_].orth)
            spans.append(entity)
            # Set custom attribute on each token of the entity
            for token in entity:
                token._.set('is_drug', True)
                # token._.set('drugbank_id', None)
            # Overwrite doc.ents and add entity – be careful not to replace!
            doc.ents = list(doc.ents) + [entity]
        for span in spans:
            # Iterate over all spans and merge them into one token. This is done
            # after setting the entities – otherwise, it would cause mismatched
            # indices!
            span.merge()
        return doc  # don't forget to return the Doc!

    def has_drug(self, tokens):
        """Getter for Doc and Span attributes. Returns True if one of the tokens
        is a drug. Since the getter is only called when we access the
        attribute, we can refer to the Token's 'is_drug' attribute here,
        which is already set in the processing step."""
        return any([t._.get('is_drug') for t in tokens])

# drugbank_matcher = DrugBankMatcher(nlp=nlp, drugs=drug_names_list)  

class DrugBankRecogniser():
  
    def __init__(self, nlp=None, texts=None, matcher=None, stoplist=None):
        self.matcher = matcher
        self.nlp = nlp
        # add the DrugBank matcher to the pipeline
        self.nlp.add_pipe(self.matcher, last=True)  # add last to the pipeline
        self.outfilename = "data/drug_annotations.txt"
        self.drugs_outfilename = "data/recognised_drugs.csv"
        if os.path.exists(self.outfilename):
            os.remove(self.outfilename)
        if os.path.exists(self.drugs_outfilename):
            os.remove(self.drugs_outfilename)
        self.drug_fieldnames = ['trial_number','drug_id','start_char', 'end_char', 'recognised_text']
        self.csvfile = open(self.drugs_outfilename, 'w', newline='')
        self.csvwriter = csv.writer(self.csvfile)
        self.csvwriter.writerow(self.drug_fieldnames)
        print('DRUG ANNOTATION RESULTS', file=open(self.outfilename, "x"))
        self.outfile=open(self.outfilename, "a")
        self.stoplist = stoplist
        self.texts = texts
        self.num_texts = len(self.texts)
        self.i = -1

    def __iter__(self):
        return self
          
    def __next__(self):
        self.i += 1
        if self.i < self.num_texts:
            trial_number, text = self.texts[self.i]
            text = text.replace('\n','  ')
            doc = self.nlp(text)
            if doc._.has_drug:
                recognised_drug_entities = []
                for e in doc.ents:
                    if e.label_.startswith('DB') and e.label_[2:7].isnumeric() and \
                        len(e.text) > 1 and e.text.lower() not in self.stoplist:
                        recognised_drug_entities.append((e.text, e.label_, e.start_char, e.end_char))
                        self.csvwriter.writerow([trial_number, e.label_, e.start_char, e.end_char, e.text])
                if len(recognised_drug_entities) > 0:
                    print('*********************', file=self.outfile)
                    print('Trial number:', trial_number, file=self.outfile)
                    print('Interventions text:', doc.text, file=self.outfile)
                    print('Recognised DrugBank.ca entities:', recognised_drug_entities, file=self.outfile)
            return self.i        
        else:
            self.csvfile.close()
            self.outfile.close()
            raise StopIteration()

trained_matcher = drugbank_matcher.matcher

drugbank_recogniser = DrugBankRecogniser(nlp=drugbank_matcher.nlp, texts=interventions_list, matcher=trained_matcher, stoplist=drug_names_stop_list)
