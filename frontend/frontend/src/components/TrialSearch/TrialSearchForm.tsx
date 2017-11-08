import * as React from 'react';
import { connect } from 'react-redux';
import { Icon, Table, Menu, MenuItemProps, Tab, TabProps, Form, Header, Button, Input } from 'semantic-ui-react'
import { returnType } from "../../utils/redux/typeUtils";
import { bindActionCreators } from "redux";
import { RootDispatch, RootState } from "../../store";
import { push } from 'react-router-redux'
import { Route, Switch, Link } from 'react-router-dom'
import { match } from "react-router";
import { searchStart, setTypedDisease, setTypedGenes, searchDone, searchError, doSearch } from '../../reducers/searchReducer';
import { SyntheticEvent } from "react";

const TrialSearchFormRender = (props: TrialSearchFormProps) => {

    return (
        <Form>
            <Form.Field>
                <label>Genes</label>
                <Input placeholder='Genes' value={props.genes} onChange={props.setTypedGenes} />
            </Form.Field>
            <Form.Field>
                <label>Disease (optional)</label>
                <Input placeholder='Disease' value={props.disease} onChange={props.setTypedDisease} />
            </Form.Field>
            <Button type='submit' onClick={() => props.doSearch(props.genes, props.disease)} content='Search' icon='search' labelPosition='left'></Button>
        </Form>
    )
}


const dispatchGeneric = returnType(mapDispatchToProps);
const stateGeneric = returnType(mapStateToProps);
type DispatchProps = typeof dispatchGeneric;
type StateProps = typeof stateGeneric;

interface TrialSearchFormOwnProps {
}
type TrialSearchFormProps =
    StateProps &
    DispatchProps &
    TrialSearchFormOwnProps;

function mapStateToProps<TrialSearchFormStateProps>(state: RootState) {
    return {
        genes: state.search.typedGenes,
        disease: state.search.typedDisease,
    };
}
function mapDispatchToProps<TrialSearchFormDispatchProps>(dispatch: RootDispatch) {
    return {
        setTypedGenes(event: SyntheticEvent<HTMLInputElement>, data: any) {
             dispatch(setTypedGenes(data.value))
        },
        setTypedDisease(event: SyntheticEvent<HTMLInputElement>, data: any) {
             dispatch(setTypedDisease(data.value))
        },

        doSearch(genes:string, diseases:string) {
            dispatch(doSearch())
        },
    }
}

// function mergeProps(stateProps: Object, dispatchProps: Object, ownProps: Object) {
//     return Object.assign({}, ownProps, stateProps, dispatchProps);
// }

export const TrialSearchForm =
    connect<StateProps, DispatchProps, {}>
        (mapStateToProps, mapDispatchToProps)
        (TrialSearchFormRender);