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
nlp = spacy.load('en')

class DrugBankMatcherTrainer():

    def __init__(self, nlp=nlp, drugs=list()):
        self.nlp = nlp
        self.vocab = self.nlp.vocab
        self.drugs = drugs
        self.matcher = Matcher(self.vocab)
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
          
drugbank_matcher_trainer = DrugBankMatcherTrainer(nlp=nlp, drugs=drug_names_list)  
