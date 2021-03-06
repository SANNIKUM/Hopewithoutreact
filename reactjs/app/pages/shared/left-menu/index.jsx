import React from "react";
import { connect } from 'react-redux';
import { Link,IndexLink  } from 'react-router';
import { MenuItem } from  '../controls/menu-item-control/';
import {dashboardActionTypes} from "../../dashboard/actions/dashboardActionTypes";
import {adminActionTypes} from "../../admin/actions/adminActionTypes";
import {sharedActionTypes} from "../actions/sharedActionTypes";
import { Utility } from "../../../common/utility/";
import * as Action from "../actions/action";

class LeftMenu extends React.Component{

   constructor(props){
         super(props);
		 this.onClickHandler=this.onClickHandler.bind(this);
		 this.onExpand = this.onExpand.bind(this);
		 this.onPanelClickHandler = this.onPanelClickHandler.bind(this);
   }
   /* on left menu minimized/maximize */
  onExpand(){
    this.props.dispatch(Action.getAction(sharedActionTypes.SET_LEFT_MENU_EXPANDED,{}));
	Utility.onWindowResize();
  }
 /* on link click */
  onClickHandler(tabkey){
	  this.props.dispatch(Action.getAction(sharedActionTypes.SET_TAB_CHANGE,{key : tabkey}));
  }
  /* on panel toggle */
  onPanelClickHandler(panel){
	  this.props.dispatch(Action.getAction(sharedActionTypes.SET_LEFT_MENU_TOGGLE,{panel : panel}));
  }
   render(){
      return  ( 
     <div>
		<div id="sidebar" className={"sidebar " + (this.props.sharedModel.smallScreenLeftMenuOpened ?" left_menu_small_screen_toggled ":'')}>			
			<div data-height="100%">				
				<ul className="nav">
					<li className="nav-profile">
						<div className="info">
							Quarterly Count
						</div>
					</li>
				</ul>
				
				<ul className="nav">
				{
					this.props.sharedModel.menuPanels.map((panel,ind)=>
							<li className={"has-sub" + (panel.isOpened ? " expand " : '')} key = { "panel-menu-" + ind}>
														<a href="javascript:;" onClick={(e)=> this.onPanelClickHandler(panel)}>
															<b className="caret pull-right"></b>
															<i className={panel.iconClass}></i>
															<span> {panel.text} </span>
														</a>
														<ul className={"sub-menu" + (!panel.isOpened? " displaynone ": '')}>
														{
															this.props.sharedModel.tabs.filter((tab)=> tab.category=== panel.value).map((tab,index)=>(																
																<MenuItem dispatch={this.props.dispatch} key={"tabs-leftmenu-"+index}  TabKey = {tab.key} To={ "/"+panel.value+"/"+tab.key }  Text={tab.text}  IsSelected={tab.isSelected}>																	
																</MenuItem>
																))
														}
														</ul>
												</li>)
				}		       
					<li>
						<a href="javascript:void(0)" className="sidebar-minify-btn" data-click="sidebar-minify" onClick={this.onExpand}>
							<i className={"fa "+(this.props.sharedModel.leftMenuExpaned ? "fa-angle-double-left":'') }></i>
						</a>
					</li>
			        
				</ul>
				
			</div>			
		</div>
		<div className="sidebar-bg"></div>
            </div>
            );

   }

}

const mapStateToProps = (state) => {
   return {
    sharedModel:state.sharedModel
  }
}

export default connect(mapStateToProps)(LeftMenu);