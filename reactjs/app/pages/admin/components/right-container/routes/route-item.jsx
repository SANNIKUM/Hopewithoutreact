import React from "react";
import { connect } from "react-redux";
import { Constants } from "../../../../../common/app-settings/constants";
const route_map = require("../../../../../assets/img/route-map.png");
const double_liner = require("../../../../../assets/img/double-vertical-liner.png");
const route_icon = require("../../../../../assets/img/route-icon.png");
import { Utility } from "../../../../../common/utility";

class RouteItemComponent extends React.Component
{

    constructor(props){
        super(props);
        this.getRouteClassName = this.getRouteClassName.bind(this);
    }
     // get routes class to be added based on their status
    getRouteClassName(routeObject) {
        let classname = " route-unassigned-team ";
        if (routeObject && routeObject.team && routeObject.team.length) {
            classname = " route-assigned-team ";
        }

        return classname;
    }
    render(){
         const {  routeName, routeTeam, routeId, routeObject, routeType } = this.props;
        return (
            <div className={"right-side-route-item all-routes-right " + this.getRouteClassName(routeObject) } key={routeName}  >
                    <div className="team-left">
                        { (routeObject && routeObject.team && routeObject.team.length) ? <img src={double_liner} className="double-liner" /> :'' }
                        <div className="team-details" style={{ paddingLeft: "5px" }}>
                            <label className="members-count">{Utility.getSubwayRouteName(routeObject)}  </label>
                            <label className={routeTeam === 'Unassigned Team' ? "members-route no-members unassigned-team-to-route" : "members-route margintop-10"}>{routeTeam}</label>
                            <div className="route_flags">
                                {(routeObject.properties.needsNypd && routeObject.properties.needsNypd.toLowerCase() === Constants.routeNeedNYPD.true.toLowerCase()) ? <span className="need_nypd  need_nypd_active">NYPD</span> : null}
                                {(routeObject.properties.park && routeObject.properties.park.toLowerCase() === Constants.isPark.true.toLowerCase()) ? <span className="ispark" style={(routeObject.properties.needsNypd && routeObject.properties.needsNypd.toLowerCase() === Constants.routeNeedNYPD.true.toLowerCase()) ? {marginLeft:"5px"}:{marginLeft:"0px"}}>Park</span> : null}
                            </div>
                        </div>
                        <img src={route_icon} alt="" title="View Route Map" className="route-icon routelist-route-map-icon" onClick={() => { this.props.onOpenRouteOnMapDialog(routeObject) } } />
                        
                    </div>

                    <div className="clear">
                    </div>
                </div>
        );
    }
}

const mapStatToProps = (state)=>{
    return { model:state.model };
};
export default connect(mapStatToProps)(RouteItemComponent);