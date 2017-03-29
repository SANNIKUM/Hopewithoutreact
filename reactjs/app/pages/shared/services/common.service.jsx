import fetch from "isomorphic-fetch";
import { Utility } from '../../../common/utility/'

import { API_URLs, Constants } from "../../../common/app-settings/constants";
import { LoginService } from "../../login/services/login.service";

/**
 * Set the request body and headers.
 */
var CommonService = {


  getRoleSettings: function () {
    let roleName = null;
    let logindetails = JSON.parse(localStorage.getItem("loginDetails"));
    if (!logindetails) {
      LoginService.checkLogin();
      roleName = null;
    }
    else {
      roleName = logindetails.selectedRole;
      return API_URLs[roleName];
    }
    return null;
  },
  /**
   * get current login user role
   */
  isNonAdmin: function () {
    let roleName = null;
    let logindetails = JSON.parse(localStorage.getItem("loginDetails"));
    if (!logindetails) {
      LoginService.checkLogin();
    }
    else {
      roleName = logindetails.selectedRole;
    }
    return roleName == Constants.loginUserTypes.sfUser;
  },
  isSFOUser: function () {
    let loginDetails = JSON.parse(localStorage.getItem("loginDetails"));
    let isSFOUser = false;
    if (loginDetails) {
      isSFOUser = loginDetails.isSFOUser;
    }
    return isSFOUser;
  },
  /**
  * Set the content type for graphQL.
  */
  getHeaders: function () {
    return { "content-type": "application/json" };
  },
  /**
    * Ajax call to the graphQL endpoint.
    */
  sendNonGraphQLRequest: function (assignmentNames, pageNumber, pageSize) {
    let sessionDetails = CommonService.getRoleSettings();
    if (sessionDetails) {
      let URL = Utility.stringFormat(CommonService.getRoleSettings().SURVEY_SUBMITTED_EXCEL_URL);

      return fetch(URL,
        {
          method: 'POST',
          headers: this.getHeaders(),
          body: JSON.stringify({ assignment_names: assignmentNames, page_number: pageNumber, page_size: pageSize })
        })
        .then(response => {
          if (!response.ok) {
            throw Error(response.statusText);
          }
          return response.json();
        });
    }
    else {
      LoginService.checkLogin();
      return new Promise(() => console.log("logout"), () => console.log("error"))
    }
  },
  sendRequest: function (variables, queryType, mutation) {
    let sessionDetails = CommonService.getRoleSettings();
    let JSONRequestBody;
    if (queryType == Constants.queryTypes.select)
      JSONRequestBody = JSON.stringify({ query: this.getQueryType(queryType), variables: variables });
    else if (queryType == Constants.queryTypes.mutation)
      JSONRequestBody = JSON.stringify({ query: mutation });
    if (sessionDetails) {
      return fetch(CommonService.getRoleSettings().SERVER_BASE_URL,
        {
          method: 'POST',
          body: JSONRequestBody,
          headers: this.getHeaders()
        })
        .then(response => {
          if (!response.ok) {
            throw Error(response.statusText);
          }
          return response.json();
        });
    }
    else {
      LoginService.checkLogin();
      return new Promise(() => console.log("logout"), () => console.log("error"))
    }

  },
  renderError: function (errorResponse) {
    console.log("Error :: ", errorResponse);
  },
  getGeoJSON: function (Geo_JSON_URL) {
    return fetch(Geo_JSON_URL,
      {
        method: 'GET',
      })
      .then(response => {
        if (!response.ok)
          throw Error(response.statusText);
        return response.json();
      });
  },
  downloadExcel: (assignmentName) => {
    let excelURL = Utility.stringFormat(CommonService.getRoleSettings().SURVEY_EXCEL_DOWNLOAD_URL, assignmentName);
    let method = "get";
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", excelURL);
    form.setAttribute("target", "_blank");
    document.body.appendChild(form);
    form.submit();
    form.remove();
  },

  postDownloadExcel: (params, fileName) => {
    let method = "POST"; // Set method to post by default if not specified.
    let path = CommonService.getRoleSettings().SURVEY_EXCEL_DOWNLOAD_URL;

    // The rest of this code assumes you are not using a library.
    // It can be made less wordy if you use one.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    var hiddenField1 = document.createElement("input");
    hiddenField1.setAttribute("type", "hidden");
    hiddenField1.setAttribute("name", "assignment_name");
    hiddenField1.setAttribute("value", "[" + params + "]");
    var hiddenField2 = document.createElement("input");    
    hiddenField2.setAttribute("name", "file_name");
    hiddenField2.setAttribute("value", fileName);

    form.appendChild(hiddenField1);
    form.appendChild(hiddenField2);
    
    document.body.appendChild(form);
    form.submit();
  },
  getQueryType: (queryType) => {
    return `query A($contextAssignmentIds: [Int!]!, $types: [AssignmentTypeInput]!) {
                            assignmentGraph(contextAssignmentIds: $contextAssignmentIds, types: $types) {
                              assignments {
                                id
                                name
                                label
                                assignmentType
                                {
                                  id
                                  name
                                }
                                properties
                              }
                              assignmentRelations {
                                assignment1Id
                                assignment2Id
                              }
                            }
                          }`;
  }

}

exports.CommonService = CommonService;
