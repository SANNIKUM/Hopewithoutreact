import React from  "react";
import { connect } from "react-redux";
import { Utility } from "../../../../../common/utility/";
import { Constants } from "../../../../../common/app-settings/constants";
const double_vertical_liner = require("../../../../../assets/img/double-vertical-liner.png");
const team_icon = require("../../../../../assets/img/teams-icon.png");

class CanvasserItemComponent extends React.Component{

    constructor(props){
        super(props);
    }

    render(){
            let { canvasser } = this.props;
        return (
            <div className="right-side-route-item" >
                    <div className="team-left">
                    {
                        canvasser.team.length == 0 ? <div className="canvasser-unassigned-team" /> : <img src={double_vertical_liner} className="double-liner" />
                    }

                        <div className="team-details">
                        <label className="members-count">
                        <label onClick={(e) => { this.props.onOpenEditCanvasserDialog(e, canvasser) } } className="canvasser-name ellipses"> {Utility.getCanvasserDetails(canvasser).name}</label>
                        </label>
                        <label className="ellipses">
                        {
                            <span>{Utility.getCanvasserDetails(canvasser).email}</span>
                        }
                        </label>
                        <label className="members-route">
                        {
                            <div className="ellipses">
                            <span className={(canvasser.countInstanceStatus && canvasser.countInstanceStatus.length && canvasser.countInstanceStatus[0].label == Constants.routesStatus.in_progress) ? "checkedin_user" : "not_checkedin_user"}>
                                {
                                    (canvasser.countInstanceStatus && canvasser.countInstanceStatus.length && canvasser.countInstanceStatus[0].label == Constants.routesStatus.in_progress) ? Constants.canvasserCheckedIn.checkedIn : Constants.canvasserCheckedIn.notCheckedIn
                                 }
                                </span>
                            <span className={canvasser.team.length == 0 ? 'unassigned-team' : 'canvasser-assigned-team-name'}>{canvasser.team.length == 0 ? 'Unassigned Team' : canvasser.team[0].label}</span>
                        </div>}
                        </label>
                    </div>
                    </div>
                     <div className="clear"></div>
                </div>
        );
    }
}

const mapStateToProps = (state) => {
  return {
    model: state.adminModel
  }
};
export default connect(mapStateToProps)(CanvasserItemComponent);
