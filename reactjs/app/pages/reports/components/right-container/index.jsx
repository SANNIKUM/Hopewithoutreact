import React from "react";
import { connect } from "react-redux";
import { Constants } from "../../../../common/app-settings/constants"
import { Utility } from "../../../../common/utility/"
import { reportsActionTypes } from "../../actions/reportsActionTypes";
import { sharedActionTypes } from "../../../shared/actions/sharedActionTypes";
import * as Action from "../../../shared/actions/action";
import { CommonService } from "../../../shared/services/common.service";

class ReportsRightContainerComponent extends React.Component {

  constructor(props) {
    super(props);
    this.onExpand = this.onExpand.bind(this);
    this.onExcelDownload = this.onExcelDownload.bind(this);
    this.genFile = this.genFile.bind(this);
  }
  // download excel file containing all surveys submitted yet for all sites
  onExcelDownload() {
    let assignmentNames = [this.props.sharedModel.selectedQCInstanceName, "survey"];
    let fileName = "";
    if (this.props.model.filterModel.selectedBorough) {
      assignmentNames.push(this.props.model.filterModel.selectedBorough.boroughName);
      fileName = this.props.model.filterModel.selectedBorough.boroughName;
    }
    if (this.props.model.filterModel.selectedSite) {
      assignmentNames.push(this.props.model.filterModel.selectedSite.siteName);
      fileName = this.props.model.filterModel.selectedSite.siteName;
    }
    CommonService.postDownloadExcel(assignmentNames, fileName);
  }
  // generate file
  genFile() {
    let data = this.props.model.surveySubmittedModel.data;
    if (this.props.model.filterModel.selectedSite) {
      Utility.downloadCSV(this.props.model.filterModel.selectedSite.siteName, this.props.model.surveySubmittedModel.headers, data);
    }
    else if (this.props.model.filterModel.selectedBorough) {
      Utility.downloadCSV(this.props.model.filterModel.selectedBorough.boroughName, this.props.model.surveySubmittedModel.headers, data);
    }

  }
  onExpand() {
    this.props.dispatch(Action.getAction(sharedActionTypes.SET_RIGHT_SIDE_EXPANDED, {}));
  }
  render() {


    return (
      <div>
        <div id="sidebar-right" className={"sidebar sidebar-right " + (this.props.sharedModel.smallScreenRightMenuOpened ? " right_menu_small_screen_toggled " : '')}>
          <div className="position-relative">
            <ul className="nav m-t-10">
              <li className="nav-widget">
                <div className="reports-download-excel">
                  <div className="text-center">
                    <button className="btn donwload-button" onClick={() => { this.onExcelDownload(); }}>Download <i className="fa fa-download downloadicon" aria-hidden="true"></i></button>
                  </div>
                </div>
                {/*<div className="reports-notification"> This report contains all the Surveys Submitted for all Sites.</div>*/}
              </li>
              <li className="nav-widget minify-button-container">
                <a
                  href="javascript:;"
                  className="sidebar-minify-btn right-side-bar-minify-button-admin minify-reports-button"
                  onClick={this.onExpand}>
                  <i className="fa  fa-angle-double-right"></i>
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="right-side-bar-bg-overlay">
          <a
            href="javascript:void(0);"
            className="sidebar-minify-btn right-side-bar-minify-button minify-reports-button"
            onClick={this.onExpand}>
            <i className="fa  fa-angle-double-left"></i>
          </a>
        </div>
      </div>
    );
  }

}

const mapStateToProps = (state) => {
  return { model: state.reportsModel, sharedModel: state.sharedModel }
};
export default connect(mapStateToProps)(ReportsRightContainerComponent);