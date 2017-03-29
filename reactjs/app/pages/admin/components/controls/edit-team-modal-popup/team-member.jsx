import React from "react";
import { connect } from 'react-redux';
import { AdminCMSService } from '../../../services/admin-cms.service';
import { adminActionTypes } from "../../../actions/adminActionTypes";
import * as Action from "../../../../shared/actions/action";
import { Constants } from "../../../../../common/app-settings/constants";
import { Utility } from "../../../../../common/utility";
import ConfirmDialog from '../../../../shared/controls/confirm-dialog-control';

class TeamMember extends React.Component{
    constructor(props) {
        super(props);
        this.onUserRemove = this.onUserRemove.bind(this);
        this.setLeader = this.setLeader.bind(this);  
    }

 onUserRemove(user) {
        let confirmMessage = Utility.stringFormat(Constants.messages.editTeamModal.memberRemoveConfirm, user.name, this.props.model.teamToEdit.label);
        ConfirmDialog(confirmMessage).then(
            (result) => {
                this.props.dispatch(Action.getAction(adminActionTypes.SET_POPUPLOADER_TOGGLE, true));
                AdminCMSService.destroyRelationFrom(this.props.model.teamToEdit.id, user.id ).then((response) => {
                    if (response.data.destroyAssignmentRelation) {
                        
                        this.props.dispatch(Action.getAction(adminActionTypes.REMOVE_TEAM_MEMBER, { teamId: this.props.model.teamToEdit.id, userId: user.id }));
                        this.props.dispatch(Action.getAction(adminActionTypes.SET_POPUPLOADER_TOGGLE, false));
                        AdminCMSService.getUsers(this.props.model.filterModel.selectedSite.siteId,this.props.sharedModel.selectedQCInstances)
                            .then(mappedData => {
                                this.props.dispatch(Action.getAction(adminActionTypes.SET_CANVASSERS_SEARCHED_RESULTS, mappedData.user));
                                this.props.dispatch(Action.getAction(adminActionTypes.SET_KEYWORD_SEARCH, { value: this.props.model.rightSideModel.keywordSearchCanvModel.selectedOption, convassersTabSelected:true }));                              
                               
                     });
                    } else {
                        this.props.dispatch(Action.getAction(adminActionTypes.SHOW_VALIDATION_MESSAGE, { validationMessage: Constants.messages.commonMessages.someErrorOccured, isPopup: false, type: Constants.validation.types.error.key }));
                    }
                })
                .catch((err) => {
                    this.props.dispatch(Action.getAction(adminActionTypes.SHOW_VALIDATION_MESSAGE, { validationMessage: err.message, isPopup: false, type: Constants.validation.types.error.key }));
                    this.props.dispatch(Action.getAction(adminActionTypes.SET_POPUPLOADER_TOGGLE, false));  
                    this.props.dispatch(Action.getAction(adminActionTypes.SET_KEYWORD_SEARCH, { value: this.props.model.rightSideModel.keywordSearchCanvModel.selectedOption, convassersTabSelected:true }));
                });
            },
            (result) => {
                this.props.dispatch(Action.getAction(adminActionTypes.SHOW_VALIDATION_MESSAGE, { validationMessage : Constants.emptyString}));
            }
        );
    }
    setLeader(Leader) {      
        let allLeaderIds = [];
        this.props.model.teamToEdit.user.forEach(function(user){      
            allLeaderIds.push({id:user.id,isLeader:(user.id != Leader.id ? false : (Leader.properties.isTeamLeader =="true"?false:true))});
        })
        this.props.dispatch(Action.getAction(adminActionTypes.SET_POPUPLOADER_TOGGLE, true));  
        AdminCMSService.setLeader(allLeaderIds)
                            .then(response => {
                                 this.props.dispatch(Action.getAction(adminActionTypes.SET_TEAM_LEADER, { users : allLeaderIds }));
                                 this.props.dispatch(Action.getAction(adminActionTypes.SET_POPUPLOADER_TOGGLE, false));  
                                 this.props.dispatch(Action.getAction(adminActionTypes.SET_KEYWORD_SEARCH, { value: this.props.model.rightSideModel.keywordSearchCanvModel.selectedOption, convassersTabSelected:true }));

                            }).catch((err) => 
                            {
                                this.props.dispatch(Action.getAction(adminActionTypes.SHOW_VALIDATION_MESSAGE, 
                                                                { validationMessage: err.message, isPopup: false, type: Constants.validation.types.error.key }));
                                this.props.dispatch(Action.getAction(adminActionTypes.SET_POPUPLOADER_TOGGLE, false));                    
                });
    }
    render(){
       return  <div className="team-members custom-scroll">
         {
          this.props.model.teamToEdit.user.length ?
                                this.props.model.teamToEdit.user.map((user, index) => {
                                 return (                                                          
                                        <div className="team-row "  key={"team-user-" + index}>
                                            ({(index + 1)}).<span className= {"member-name"} >{ Utility.getCanvasserDetails(user).name}</span> <span className="member-email email_absolute">{Utility.getCanvasserDetails(user).email}</span>
                                            <span className={"leader "+((user.properties.isTeamLeader=="true") ? " active ": "")} onClick={() => { this.setLeader(user) } } title={(user.properties.isTeamLeader=="false") ? "Set Team Leader" : ''} >Team Leader</span>   
                                            <span className={(user.countInstanceStatus && user.countInstanceStatus.length && user.countInstanceStatus[0].label == Constants.routesStatus.in_progress) ? "checkedin_user" : ""}>
                                            {
                                                (user.countInstanceStatus && user.countInstanceStatus.length && user.countInstanceStatus[0].label == Constants.routesStatus.in_progress) ? Constants.canvasserCheckedIn.checkedIn : Constants.emptyString
                                            }
                                            </span>                   
                                            <i className="fa fa-times-circle-o remove-row-icon" onClick={() => { this.onUserRemove(user) } } title="Remove canvasser from team."></i>
                                        </div>                                 
                                    );
                                })
                                :
                           <div className="team-row no-routes">{ Constants.messages.noTeamMember }</div>
         }
     </div>
    }
}


const mapStateToProps = (state) => {
    return {
        model: state.adminModel,
        sharedModel: state.sharedModel
    }
}

export default connect(mapStateToProps)(TeamMember);