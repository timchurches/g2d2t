import * as React from 'react';
import { Item, Icon } from 'semantic-ui-react';

import Highlighter = require("react-highlight-words");


interface HighlighterProps {
    toHighlight: string[];
}

interface TrialResultProps {
    result: any;
    genes: string[];
    disease: string;
}

export function TrialResult(props: TrialResultProps) {
    const result = props.result;

    const searchWords = [...props.genes, props.disease];

    const onLinkClicked = () => {
        const url = `http://www.anzctr.org.au/TrialSearch.aspx?searchTxt=${result.actrnumber}&isBasic=True`;
        window.open(url, "_blank");

    }

    return (
        <Item>
            {/* <Icon name="lab" /> */}
            <Item.Content>
                <Item.Header as='a' onClick={onLinkClicked}>{result.study_title}</Item.Header>
                <Item.Meta>
                    {result.recruitment_status === "Recruiting" &&
                        <Icon name="check" />
                    }
                    {result.recruitment_status}.&nbsp;
                    {result.recruitment_phase}.&nbsp;
                    {result.trial_allocation}.&nbsp;
                </Item.Meta>
                <Item.Description>
                    <p>
                        <strong>Extracted terms: </strong>
                        <span style={{color: "blue", fontWeight: "bold"}}>
                             {(result.extracted_drugs || []).join(", ")}
                        </span>
                        {(result.extracted_drugs || []).length > 0 && ", "}
                        &nbsp;&nbsp;
                        <span style={{color: "#E42217", fontWeight: "bold"}}>
                             {(result.extracted_genes || []).join(", ")}
                        </span>
                    </p>
                    <p>
                        <Highlighter
                            searchWords={searchWords} autoEscape
                            textToHighlight={result.summary || ''}
                        />
                    </p>
                    <p>
                        <strong>Interventions: </strong>
                        <Highlighter
                            searchWords={searchWords} autoEscape
                            textToHighlight={result.interventions || ''}
                        />
                    </p>
                    <p>
                        <strong>Inclusion: </strong>
                        <Highlighter
                            searchWords={searchWords} autoEscape
                            textToHighlight={result.eligibity_inclusive || ''}
                        />
                    </p>
                    <p>
                        <strong>Exclusion: </strong>
                        <Highlighter
                            searchWords={searchWords} autoEscape
                            textToHighlight={result.eligibity_exclusive || ''}
                        />
                    </p>

                </Item.Description>
                <Item.Extra>
                </Item.Extra>
            </Item.Content>
        </Item>

    )
}