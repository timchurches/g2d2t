import { TrialSearchForm } from './TrialSearchForm';
import * as React from 'react';
import { connect } from 'react-redux';
import { Icon, Table, Image, Menu, MenuItemProps, Tab, TabProps, Form, Header, Button, Loader, Item } from 'semantic-ui-react'
import { returnType } from "../../utils/redux/typeUtils";
import { bindActionCreators } from "redux";
import { RootDispatch, RootState } from "../../store";
import { push } from 'react-router-redux'
import { Route, Switch, Link } from 'react-router-dom'
import { match } from "react-router";
import { style } from "typestyle/lib";
import { TrialResult } from './TrialResult';

const styles = {
    container: style({
        margin: "1em"
    }),
    header: style({
        display: "flex",
        alignItems: "center",
    })
}

interface ResultsTabProps {
    results: any;
    genes: string[];
    disease: string;
}

function ResultsTab(props: ResultsTabProps) {
    return (
        <div>
            <Item.Group divided>
                {props.results.map((result: any) =>
                    <TrialResult key={result.actrnumber} result={result} genes={props.genes} disease={props.disease} />)}
            </Item.Group>

            {/* {props.results.length === 0 && <div>No trials</div>} */}
            <p>
                Data from the <a href="https://www.anzctr.org.au/">Australian New Zealand Clinical Trials Registry</a>
            </p>
        </div>
    )
}

const TrialSearchPageRender = (props: TrialSearchPageProps) => {

    const numFound =
        props.reply
            ? props.reply.withDiseaseCount + props.reply.withoutDiseaseCount
            : 0;

    const genes = props.genes.split(' ');

    const tabPanes = props.reply ? [
        {
            menuItem: `With disease ${props.reply.withDiseaseCount})`,
            render: () => <Tab.Pane>
                <ResultsTab results={props.reply.withDisease} genes={genes} disease={props.disease} />
            </Tab.Pane>
        },
        {
            menuItem: `Without disease (${props.reply.withoutDiseaseCount})`,
            render: () => <Tab.Pane>
                <ResultsTab results={props.reply.withoutDisease} genes={genes} disease={props.disease} />
            </Tab.Pane>
        },
    ] : [];

    const haveDisease = !!(props.disease || '');

    const resultsView =
        props.reply &&
        ((haveDisease)
            ? <Tab renderActiveOnly={true} panes={tabPanes} style={{ marginLeft: "1em", marginRight: "1em" }} />
            : <ResultsTab results={props.reply.withoutDisease} genes={genes} disease={props.disease} />);

    return (
        <div className={styles.container}>
            <div className={styles.header}>
                <Header as='h3' style={{marginRight: "2em"}}>
                    Australian Cancer Trial Gene Matcher - G2D2T - (Alpha version)
                </Header>
                <Image.Group size='small'>
                    <Image src='/build/healthhack.png' />
                    <Image src='/build/kinghorn.jpg' />
                </Image.Group>
            </div>

            <TrialSearchForm />

            {props.loading && <Loader inline />}

            {props.reply && (
                <p><br />{numFound} trials found</p>
            )}
            {resultsView}
        </div>
    )
}

const dispatchGeneric = returnType(mapDispatchToProps);
const stateGeneric = returnType(mapStateToProps);
type DispatchProps = typeof dispatchGeneric;
type StateProps = typeof stateGeneric;

interface TrialSearchPageOwnProps {
}
type TrialSearchPageProps =
    StateProps &
    DispatchProps &
    TrialSearchPageOwnProps;

function mapStateToProps<TrialSearchPageStateProps>(state: RootState) {
    return {
        loading: state.search.searching,
        reply: state.search.reply,
        genes: state.search.typedGenes,
        disease: state.search.typedDisease,
    };
}
function mapDispatchToProps<TrialSearchPageDispatchProps>(dispatch: RootDispatch) {
    return bindActionCreators({
    }, dispatch);
}

function mergeProps(stateProps: Object, dispatchProps: Object, ownProps: Object) {
    return Object.assign({}, ownProps, stateProps, dispatchProps);
}

export const TrialSearchPage =
    connect<StateProps, DispatchProps, {}>
        (mapStateToProps, mapDispatchToProps)
        (TrialSearchPageRender);