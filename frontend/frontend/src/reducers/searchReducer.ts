import { createActionHandler, createReducer } from '../utils/redux'
import { actionType, createActionConstantsMap, createActionCreator } from '../utils/redux';
import { RootDispatch } from '../store';

export interface SearchState {
    typedGenes: string
    typedDisease: string

    searching: boolean
    searchError: string | null
    reply: any | null
}
export const actions = createActionConstantsMap('waitingRoom', {
    SET_TYPED_GENES: actionType<string>(),
    SET_TYPED_DISEASE: actionType<string>(),

    SEARCH_START: actionType<{}>(),
    SEARCH_DONE: actionType<any>(),
    SEARCH_ERROR: actionType<string>(),

});
export const setTypedGenes = createActionCreator(actions.SET_TYPED_GENES);
export const setTypedDisease = createActionCreator(actions.SET_TYPED_DISEASE);

export const searchStart = createActionCreator(actions.SEARCH_START);
export const searchDone = createActionCreator(actions.SEARCH_DONE);
export const searchError = createActionCreator(actions.SEARCH_ERROR);


export function doSearch() {
    console.log("action");
    return function (dispatch2: RootDispatch, getState:any) {
        const state = getState();
        console.log("thunk", state);
        dispatch2(searchStart({}))

        const genes = state.search.typedGenes;
        const disease = state.search.typedDisease;

        return fetch(`/searchTrials?genes=${encodeURIComponent(genes)}&disease=${encodeURIComponent(disease)}`)
            .then(response => response.json(),
            error => dispatch2(searchError(error)))
            .then(json => dispatch2(searchDone(json)))
    }

}

const initialState: SearchState = {
    typedGenes: "BRAF",
    typedDisease: "",

    searching: false,
    searchError: null,
    reply: null,
}


function recruitmentStatusToScore(status:string) {

    if (status === "Recruiting") {
        return "0";
    } else {
        return status || "";
    }
}

const handleAction = createActionHandler<SearchState>();
export const searchReducer = createReducer(initialState, [
    handleAction(actions.SET_TYPED_GENES, (state, action) => {
        return { ...state, reply: null, typedGenes: action.payload.toUpperCase() }
    }),
    handleAction(actions.SET_TYPED_DISEASE, (state, action) => {
        return { ...state, reply: null, typedDisease: action.payload }
    }),

    handleAction(actions.SEARCH_START, (state, action) => {
        return { ...state, searching: true }
    }),
    handleAction(actions.SEARCH_DONE, (state, action) => {
        const reply = action.payload;
        /********************************
        sort
        ********************************/
        reply.withDisease.sort( (a:any,b:any) => {
            const sa = recruitmentStatusToScore(a.recruitment_status);
            const sb = recruitmentStatusToScore(b.recruitment_status);
            return sa.localeCompare( sb );
        });
        reply.withoutDisease.sort( (a:any,b:any) => {
            const sa = recruitmentStatusToScore(a.recruitment_status);
            const sb = recruitmentStatusToScore(b.recruitment_status);
            return sa.localeCompare( sb );
        });

        return { ...state, searching: false, reply, searchError: null }
    }),
    handleAction(actions.SEARCH_ERROR, (state, action) => {
        return { ...state, searching: false, reply: null, searchError: action.payload }
    }),
]);
