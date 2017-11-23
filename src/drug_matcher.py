#!/usr/bin/env python
# coding: utf8

#  Custom pipeline components: https://spacy.io//usage/processing-pipelines#custom-components
# Compatible with: spaCy v2.0.0+

# from __future__ import unicode_literals, print_function
import plac
import feather
import pandas as pd
# from tqdm import tqdm
import os, sys, csv

from spacy.lang.en import English
from spacy.matcher import Matcher
from spacy.tokens import Doc, Span, Token
from spacy import displacy
import spacy

path_prefix = "/Users/tim.churches/g2d2t/"

drug_names_path = path_prefix + "data/drug_names.feather"
drug_names_df = feather.read_dataframe(drug_names_path)
a = drug_names_df['drug_id'].tolist()
b = drug_names_df['term'].tolist()
drug_names_list = [(a[i], b[i]) for i in range(len(a))]

with open(path_prefix + 'src/drugbank_stoplist.txt') as f:
    drug_names_stop_list = [w.lower() for w in f.read().splitlines()]

interventions_path = path_prefix + "data/interventions.feather"
interventions_df = feather.read_dataframe(interventions_path)
a = interventions_df['trial_number'].tolist()
b = interventions_df['interventions'].tolist()
interventions_list = [(a[i], b[i]) for i in range(len(a))]


def main(texts=interventions_list, drug_names=drug_names_list, stoplist=drug_names_stop_list):
    # Use the standard en pipeline
    nlp = spacy.load('en')
    # Output files
    outfilename = path_prefix + "data/drug_annotations.txt"
    if os.path.exists(outfilename):
      os.remove(outfilename)
    drugs_outfilename = path_prefix + "data/recognised_drugs.csv"
    if os.path.exists(drugs_outfilename):
      os.remove(drugs_outfilename)
    trainer_progress_file = path_prefix + "data/trainer_progress.txt"
    tfile = open(trainer_progress_file, "w")
    print("0,0", file=tfile)
    tfile.close()
    recogniser_progress_file = path_prefix + "data/recogniser_progress.txt"
    rfile = open(recogniser_progress_file, "w")
    print("0,0", file=rfile)
    rfile.close()
    output_feather_path = path_prefix + "data/recognised_drug_names.feather"
    if os.path.exists(output_feather_path):
      os.remove(output_feather_path)
    nlp_status_file = path_prefix + "data/nlp_status.txt"    
    # create the drug recogniser
    component = DrugBankRecogniser(nlp, drugs=drug_names, progress_file=trainer_progress_file)  
    nlp.add_pipe(component, last=True)  # add last to the pipeline
    drug_fieldnames = ['trial_number','drug_id','start_char', 'end_char', 'recognised_text']
    csvfile = open(drugs_outfilename, 'w', newline='')
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(drug_fieldnames)
    print('DRUG ANNOTATION RESULTS', file=open(outfilename, "x"))
    outfile=open(outfilename, "a")
    num_texts = len(texts)
    t = 0
    # for trial_number, text in tqdm(texts, desc="Drug-tagging:"):
    output_list = []
    for trial_number, text in texts:
      t += 1
      print(str(t) + "," + str(num_texts), file=open(recogniser_progress_file, "w"))
      text = text.replace('\n','  ')
      doc = nlp(text)
      if doc._.has_drug:
        recognised_drug_entities = []
        for e in doc.ents:
          if e.label_.startswith('DB') and e.label_[2:7].isnumeric() and \
                        len(e.text) > 1 and e.text.lower() not in stoplist:
            recognised_drug_entities.append((e.text, e.label_, e.start_char, e.end_char))
            outrow = [trial_number, e.label_, e.start_char, e.end_char, e.text]
            csvwriter.writerow(outrow)
            output_list.append(outrow)
        if len(recognised_drug_entities) > 0:
          print('*********************', file=outfile)
          print('Trial number:', trial_number, file=outfile)
          print('Interventions text:', doc.text, file=outfile)
          print('Recognised DrugBank.ca entities:', recognised_drug_entities, file=outfile)
    csvfile.close()
    outfile.close()
    output_df = pd.DataFrame(output_list, columns=('trial_number', 'drug_id', 'start_char', 'end_char', 'recognised_text'))
    output_df.to_feather(output_feather_path)
    ofile = open(nlp_status_file, "w")
    print("1", file=ofile)
    ofile.close()
    sys.exit()
    
class DrugBankRecogniser(object):
    """A spaCy v2.0 pipeline component that sets entity annotations
    based on list of single or multiple-word drug names. Drugs are
    labelled with their DrugBank ID (key) and their spans are merged into one token. Additionally,
    ._.has_drug and ._.is_drug are set on the Doc/Span and Token
    respectively."""
    name = 'drugbank_recogniser'  # component name, will show up in the pipeline

    def __init__(self, nlp, drugs=list(), stopwords=list(), progress_file=""):
        """Initialise the pipeline component. The shared nlp instance is used
        to initialise the matcher with the shared vocab, get the label ID and
        generate Doc objects as phrase match patterns.
        """
        self.vocab = nlp.vocab

        self.matcher = Matcher(nlp.vocab)
        #drug_counter = 0
        num_drugs = len(drugs)
        t = 0
        # for drug_id, drug_term in tqdm(drugs, desc='Adding drug matchers: '):
        for drug_id, drug_term in drugs:
          t += 1
          if t % 10 == 0 or t ==num_drugs:
            print(str(t) + "," + str(num_drugs), file=open(progress_file, "w"))
          if drug_term is not None:
            pattern_dict_list = []
            drug_doc = nlp(drug_term)
            for tok in drug_doc:
              if tok.is_punct:
                pattern_dict_list.append({'OP': '*', 'IS_PUNCT': True})
              else: 
                pattern_dict_list.append({'LOWER': tok.lower})
            if len(pattern_dict_list) > 0:
              self.matcher.add(drug_id, None, pattern_dict_list)

        # Register attribute on the Token. We'll be overwriting this based on
        # the matches, so we're only setting a default value, not a getter.
        Token.set_extension('is_drug', default=False)

        # Register attributes on Doc and Span via a getter that checks if one of
        # the contained tokens is set to is_drug == True.
        Doc.set_extension('has_drug', getter=self.has_drug)
        Span.set_extension('has_drug', getter=self.has_drug)

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

if __name__ == '__main__':
   plac.call(main)
