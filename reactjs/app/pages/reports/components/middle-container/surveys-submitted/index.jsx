import React from "react";
import { connect } from "react-redux";
import Select from "react-select";
import { Constants } from "../../../../../common/app-settings/constants"
import { sharedActionTypes } from "../../../../shared/actions/sharedActionTypes";
import { CommonService } from "../../../../shared/services/common.service";
import { reportsActionTypes } from "../../../actions/reportsActionTypes";
import * as Action from "../../../../shared/actions/action";
import { menuRenderer } from "../../../../shared/controls/menu-renderer";
import { ReportsService } from "../../../services/reports.service";
import { Utility } from "../../../../../common/utility/"
// in ECMAScript 6
import { BootstrapTable, TableHeaderColumn } from 'react-bootstrap-table';


class SurveysSubmittedComponent extends React.Component {

    constructor(props) {
        super(props);
        this.onExcelDownload = this.onExcelDownload.bind(this);
        this.siteFilterOptions = this.siteFilterOptions.bind(this);
        this.boroughsFilterOptions = this.boroughsFilterOptions.bind(this);
        this.onBoroughChange = this.onBoroughChange.bind(this);
        this.onSiteChange = this.onSiteChange.bind(this);
        this.fetchBoroughsAndSites = this.fetchBoroughsAndSites.bind(this);
        this.getSurveysList = this.getSurveysList.bind(this);
        this.disableScroll = this.disableScroll.bind(this);
        this.showErrorMessage = this.showErrorMessage.bind(this);
        this.getAssignmentNames = this.getAssignmentNames.bind(this);
        this.boolConverterType = {
            'true': 'Yes',
            'false': 'No',
        };
    }
    /**
    * Set tab to DownloadSurveys on component mount.
    */
    componentDidMount() {
        this.fetchBoroughsAndSites();
        this.props.dispatch(Action.getAction(sharedActionTypes.SET_TAB_CHANGE, { key: Constants.reportsViewKeys.surveysSubmitted }));
        this.props.model.filterModel.selectedBorough = null;
        this.props.model.filterModel.selectedSite = null;
    }
    // download excel file containing all surveys submitted yet for all sites
    onExcelDownload() {

        console.log("onExcelDownload", this.props.model.filterModel.selectedSite);
        CommonService.downloadExcel("assignmentName");
    }
    /**
     * Filter sites for selected borough.
     */
    siteFilterOptions(sites, selectedBorough) {
        if (selectedBorough) {
            this.sitesOptions = sites && sites.filter((site) => (site.boroughId == selectedBorough.boroughId));
            // if there is only one site make that selected in drop down
            let allSites = this.sitesOptions && this.sitesOptions.filter(m => m.siteId != -1);
            if (allSites && allSites.length == 1)
                this.sitesOptions = allSites;
        }
    }

    /**
     * Sort boroughs.
     */
    boroughsFilterOptions(boroughs) {
        this.boroughsOptions = boroughs && boroughs.sort(function (a, b) {
            let value = 0;
            a.boroughName < b.boroughName ? (value = -1) : (a.boroughName > b.boroughName ? (value = 1) : (value = 0));
            return value;
        })

        // if there is only one borough set that selected 
        let allboroughs = boroughs && boroughs.filter(m => m.boroughId != -1);
        if (allboroughs && allboroughs.length == 1) {
            boroughs = allboroughs;
        }
    }
    componentWillUnmount() {
        this.props.dispatch(Action.getAction(reportsActionTypes.SET_PANEL_RELOAD_REPORTS, false));
    }

    onBoroughChange(boroughObject) {
        // debugger;
        this.props.dispatch(Action.getAction(reportsActionTypes.SET_BOROUGH_REPORTS, { value: boroughObject }));
        let assignmentNames = [this.props.sharedModel.selectedQCInstanceName, "survey"];

        assignmentNames.push(boroughObject.boroughName);
        // debugger;
        this.getSurveysList(assignmentNames, 1, this.props.model.surveySubmittedModel.submittedSurveyGridModel.perPage);
    }

    onSiteChange(siteObject) {
        this.props.dispatch(Action.getAction(reportsActionTypes.SET_SITE_REPORTS, { value: siteObject }));
        let assignmentNames = [this.props.sharedModel.selectedQCInstanceName,"survey"];
        assignmentNames.push(this.props.model.filterModel.selectedBorough.boroughName)
        assignmentNames.push(siteObject.siteName);
        // debugger;
        this.getSurveysList(assignmentNames, 1, this.props.model.surveySubmittedModel.submittedSurveyGridModel.perPage);
    }

    fetchBoroughsAndSites() {
        ReportsService.getBoroughsAndSites(this.props.sharedModel.selectedQCInstances).then(
            (response) => {
                this.props.dispatch(Action.getAction(reportsActionTypes.SET_BOROUGHS_AND_SITES_REPORTS, response));
                // if there is site selcted then fetch all teams of this site
                if (this.props.model.filterModel.selectedSite)
                    this.onSiteChange(this.props.model.filterModel.selectedSite);
            }
        ).catch((error) => {
            this.showErrorMessage(Constants.messages.commonMessages.someErrorOccured, Constants.validation.types.error);
        });
    }
    // disable scroll while loading
    disableScroll() {
        if (this.props.model.panelProperties.panelReload)
            return { "overflow": "hidden" };
        else null;
    }
    //show hide error meessages
    showErrorMessage(message, errorType) {
        this.props.dispatch(Action.getAction(reportsActionTypes.SHOW_VALIDATION_MESSAGE, { validationMessage: message, type: errorType.key }));
        if (message)
            window.setTimeout(() => {
                this.props.dispatch(Action.getAction(reportsActionTypes.SHOW_VALIDATION_MESSAGE, { validationMessage: Constants.emptyString, type: errorType.key }));
            }, Constants.messages.defaultMessageTimeout)
    }
    // get surveys
    getSurveysList(assignmentNames, pageNumber, pageSize) {
        this.props.dispatch(Action.getAction(reportsActionTypes.SET_PANEL_RELOAD_REPORTS, true));
        ReportsService.getSurveySubmittedList(
            assignmentNames,
            pageNumber, pageSize).then(response => {
                this.props.dispatch(Action.getAction(reportsActionTypes.SET_PANEL_RELOAD_REPORTS, false));
                this.props.dispatch(Action.getAction(reportsActionTypes.SET_REPORTS_SURVEYS_SUBMITTED_LIST,
                    {
                        value: Utility.convertSurveySubmittedCSVDataToJSON(response.arr),
                        headerAnddata: response.arr,
                        submittedSurveyGridModel: response
                    }));
            }).catch(error => {
                this.props.dispatch(Action.getAction(reportsActionTypes.SET_PANEL_RELOAD_REPORTS, false));
                this.showErrorMessage(Constants.messages.commonMessages.someErrorOccured, Constants.validation.types.error);
            })
    }

    enumFormatter(cell, row, enumObject) {
        return enumObject[cell];
    }
    getAssignmentNames() {
        let assignmentNames = [this.props.sharedModel.selectedQCInstanceName,"survey"];

        if (this.props.model.filterModel.selectedBorough) {
            assignmentNames.push(this.props.model.filterModel.selectedBorough.boroughName);
        }
        if (this.props.model.filterModel.selectedSite) {
            assignmentNames.push(this.props.model.filterModel.selectedSite.siteName);
        }

        return assignmentNames;
    }

    sizePerPageListChange(sizePerPage) {
        this.getSurveysList(this.getAssignmentNames(), this.props.model.surveySubmittedModel.submittedSurveyGridModel.currentPage, this.props.model.surveySubmittedModel.submittedSurveyGridModel.perPage);
    }

    onPageChange(page, sizePerPage) {
        this.getSurveysList(this.getAssignmentNames(), page, this.props.model.surveySubmittedModel.submittedSurveyGridModel.perPage);
    }

    renderShowsTotal(start, to, total) {
        return (
            <p>
                {Utility.stringFormat(Constants.messages.reportsModel.paginationShowsSummary, start, to) + ", "}<b>{Utility.stringFormat(Constants.messages.reportsModel.paginationShowsTotal, total)}</b>
            </p>
        );
    }
    render() {
        const options = {
            paginationShowsTotal: this.renderShowsTotal.bind(this),
            onPageChange: this.onPageChange.bind(this),
            onSizePerPageList: this.sizePerPageListChange.bind(this),
            page: this.props.model.surveySubmittedModel.submittedSurveyGridModel.currentPage,
            sizePerPage: this.props.model.surveySubmittedModel.submittedSurveyGridModel.perPage,
            pageStartIndex: 1, // where to start counting the pages
            paginationSize: 5,  // the pagination bar size.
            prePage: 'Prev', // Previous page button text
            nextPage: 'Next', // Next page button text
            firstPage: 'First', // First page button text
            lastPage: 'Last', // Last page button text
            hideSizePerPage: true,// > You can hide the dropdown for sizePerPage
            alwaysShowAllBtns: true, // Always show next and previous button
            withFirstAndLast: true //> Hide the going to First and Last page button
        };
        let reportsModel = this.props.model;
        return (
            <div>
                <div className="admin-filter-bar">
                    <table cellSpacing="0" cellPadding="0" >
                        <tbody>
                            <tr>
                                <td className="filter-boroughs">
                                    <label>
                                        Borough<span className="asterik-white">*</span>
                                    </label>
                                    <Select value={reportsModel.filterModel.selectedBorough} valueKey="boroughId" labelKey="boroughName" searchable={false} clearable={false}
                                        menuRenderer={menuRenderer} filterOptions={this.boroughsFilterOptions(reportsModel.filterModel.boroughs)}
                                        name="form-field-name" onChange={this.onBoroughChange} options={this.boroughsOptions} disabled={reportsModel.panelProperties.panelReload} />
                                </td>

                                <td className="filter-sites">
                                    <label>
                                        Site<span className="asterik-white">*</span>
                                    </label>
                                    <Select value={reportsModel.filterModel.selectedSite} valueKey="siteId" labelKey="siteName" searchable={false} clearable={false}
                                        menuRenderer={menuRenderer} filterOptions={this.siteFilterOptions(reportsModel.filterModel.sites, reportsModel.filterModel.selectedBorough)} name="form-field-name" onChange={this.onSiteChange}
                                        options={this.sitesOptions} disabled={reportsModel.panelProperties.panelReload} />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div className="survey-grid-position-relative custom-scroll-bar">
                    <BootstrapTable options={options}
                        fetchInfo={{ dataTotalSize: reportsModel.surveySubmittedModel.submittedSurveyGridModel.totalEntries }}
                        data={reportsModel.surveySubmittedModel.jsonData}
                        pagination
                        remote
                        striped
                        hover
                        condensed
                    >
                        <TableHeaderColumn dataField='requestId' isKey={true} hidden={true} dataAlign='center'>Request Id</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataField='submittedAt' dataAlign='center'>Submitted At</TableHeaderColumn>
                        <TableHeaderColumn width='110' className='td-header-string-example' dataField='latitude' dataAlign='center'>Latitude</TableHeaderColumn>
                        <TableHeaderColumn width='110' className='td-header-string-example' dataField='longitude' dataAlign='center'>Longitude</TableHeaderColumn>
                        <TableHeaderColumn width='300' className='td-header-string-example' dataAlign='center' dataField='user'>User</TableHeaderColumn>
                        <TableHeaderColumn width='150' dataFormat={this.enumFormatter} formatExtraData={this.boolConverterType} className='td-header-string-example' dataAlign='center' dataField='user: isTeamLeader'>User: isTeamLeader</TableHeaderColumn>
                        <TableHeaderColumn width='200' className='td-header-string-example' dataAlign='center' dataField='site'>Site</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='route'>Route</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='route: type'>Route: Type</TableHeaderColumn>
                        <TableHeaderColumn width='200' className='td-header-string-example' dataAlign='center' dataField='route: route (subway)'>Route: Route (Subway)</TableHeaderColumn>
                        <TableHeaderColumn width='120' className='td-header-string-example' dataAlign='center' dataField='route: station'>Route: Station</TableHeaderColumn>
                        <TableHeaderColumn width='140' className='td-header-string-example' dataAlign='center' dataField='route: endOfLine'>Route: End Of Line</TableHeaderColumn>
                        <TableHeaderColumn width='150' dataFormat={this.enumFormatter} formatExtraData={this.boolConverterType} className='td-header-string-example' dataAlign='center' dataField='route: needs_nypd'>Route: Needs NYPD</TableHeaderColumn>
                        <TableHeaderColumn width='200' className='td-header-string-example' dataAlign='center' dataField='team'>Team</TableHeaderColumn>
                        <TableHeaderColumn width='130' className='td-header-string-example' dataAlign='center' dataField='locationDetails'>Location Details</TableHeaderColumn>
                        <TableHeaderColumn width='130' className='td-header-string-example' dataAlign='center' dataField='seemsHomeless'>Seems Homeless</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='awake'>Awake</TableHeaderColumn>
                        <TableHeaderColumn width='120' className='td-header-string-example' dataAlign='center' dataField='canInterview?'>Can Interview?</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='interviewedAlready?'>Interviewed Already?</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataAlign='center' dataField='doYouHaveHome?'>Do You Have Home?</TableHeaderColumn>
                        <TableHeaderColumn width='250' className='td-header-string-example' dataAlign='center' dataField='whereDoYouLive?'>Where Do You Live?</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='age?'>Age?</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='sex'>Sex</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='veteran?'>Veteran?</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataAlign='center' dataField='veteranWasActive?'>Veteran Was Active?</TableHeaderColumn>
                        <TableHeaderColumn width='100' className='td-header-string-example' dataAlign='center' dataField='race'>Race</TableHeaderColumn>
                        <TableHeaderColumn width='160' className='td-header-string-example' dataAlign='center' dataField='firstTimeHomeless?'>First Time Homeless?</TableHeaderColumn>
                        <TableHeaderColumn width='300' className='td-header-string-example' dataAlign='center' dataField='dontKnowOrRefusedToAnswerChronicity?'>Don't Know Or Refused To Answer Chronicity?</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataAlign='center' dataField='daysHomeless?'>Days Homeless?</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataAlign='center' dataField='weeksHomeless?'>Weeks Homeless?</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataAlign='center' dataField='monthsHomeless?'>Months Homeless?</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataAlign='center' dataField='yearsHomeless?'>Years Homeless?</TableHeaderColumn>
                        <TableHeaderColumn width='220' className='td-header-string-example' dataAlign='center' dataField='timesHomelessInPast4Years?'>Times Homeless In Past 4 Years?</TableHeaderColumn>
                        <TableHeaderColumn width='400' className='td-header-string-example' dataAlign='center' dataField='dontKnowOrRefusedToAnswerChronicityForPast3Years?'>Don't Know Or Refused To Answer Chronicity For Past 3 Years?</TableHeaderColumn>
                        <TableHeaderColumn width='220' className='td-header-string-example' dataAlign='center' dataField='daysHomelessInPast3Years?'>Days Homeless In Past 3 Years?</TableHeaderColumn>
                        <TableHeaderColumn width='230' className='td-header-string-example' dataAlign='center' dataField='weeksHomelessInPast3Years?'>Weeks Homeless In Past 3 Years?</TableHeaderColumn>
                        <TableHeaderColumn width='230' className='td-header-string-example' dataAlign='center' dataField='monthsHomelessInPast3Years?'>Months Homeless In Past 3 Years?</TableHeaderColumn>
                        <TableHeaderColumn width='220' className='td-header-string-example' dataAlign='center' dataField='yearsHomelessInPast3Years?'>Years Homeless In Past 3 Years?</TableHeaderColumn>
                        <TableHeaderColumn width='220' className='td-header-string-example' dataAlign='center' dataField='route: multipolygon_coordinates'>Route: Multipolygon Coordinates</TableHeaderColumn>
                        <TableHeaderColumn width='220' className='td-header-string-example' dataAlign='center' dataField='route: point_coordinates'>Route: Point Coordinates</TableHeaderColumn>
                        <TableHeaderColumn width='180' className='td-header-string-example' dataAlign='center' dataField='uniqueCharacteristics'>Unique Characteristics</TableHeaderColumn>
                        <TableHeaderColumn width='150' className='td-header-string-example' dataAlign='center' dataField='decoyCode'>Decoy Code</TableHeaderColumn>
                        <TableHeaderColumn width='180' className='td-header-string-example' dataAlign='center' dataField='user: firstName'>User: First Name</TableHeaderColumn>
                        <TableHeaderColumn width='180' className='td-header-string-example' dataAlign='center' dataField='user: lastName'>User: Last Name</TableHeaderColumn>
                        <TableHeaderColumn width='180' className='td-header-string-example' dataAlign='center' dataField='user: email'>User: Email</TableHeaderColumn>
                        <TableHeaderColumn width='150' dataFormat={this.enumFormatter} formatExtraData={this.boolConverterType} className='td-header-string-example' dataAlign='center' dataField='isSoftDeleted'>Is Soft Deleted</TableHeaderColumn>
                    </BootstrapTable>
                    {reportsModel.panelProperties.panelReload ? <div className="panel-loader"><span className="spinner-small"></span></div> : ''}
                </div>
            </div>

        );
    }
}

const mapStateToProps = (state) => {
    return {
        model: state.reportsModel,
        sharedModel: state.sharedModel
    };
}
export default connect(mapStateToProps)(SurveysSubmittedComponent);;