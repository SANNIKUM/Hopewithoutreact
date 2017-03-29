import {Constants} from "../../../common/app-settings/constants"

// admin section state
export const adminState = {
            "panelProperties": {
                "panelAutoReloadInterval": "2m",
                "lastUpdatedOn": null,
                "panelExpanded": false,
                "displayRefreshButton": true,
                "panelReload": false,
                "panelCollapsed": false,
                "panelRemoved": false
            },
            "createTeamModel": {
                "teamName": "",
                "selectedBorough": null,
                "selectedSite": null
            },
            "filterModel": {
                "boroughs": [],
                "sites": [],
                "selectedBorough": null,
                "selectedSite": null
            },
            "rightSideModel": {
                "createCanvasserModalIsOpened": false,
                "editCanvasser": {},
                "keywordSearchCanvModel": {
                "selectedOption": null
                },
                "keywordSearchRoutesModel": {
                "selectedOption": null
                },
                "statusModel": {
                "selectedCanvOption": {
                    "label": "All",
                    "value": "All"
                },
                "selectedRoutesOption": {
                    "label": "All",
                    "value": "All"
                },
                "options": [
                    {
                    "type": "canvasser",
                    "label": "All",
                    "value": "All"
                    },
                    {
                    "type": "canvasser",
                    "label": "Assigned",
                    "value": "assigned"
                    },
                    {
                    "type": "canvasser",
                    "label": "UnAssigned",
                    "value": "unAssigned"
                    },
                    {
                    "type": "route",
                    "label": "All",
                    "value": "All"
                    },
                    {
                    "type": "route",
                    "label": "Assigned",
                    "value": "assigned"
                    },
                    {
                    "type": "route",
                    "label": "UnAssigned",
                    "value": "unAssigned"
                    }
                ]
                },
                "searchedCanvassers": [],
                "initialSearchedRoutes": [],
                "initialSearchedCanvassers": [],
                "searchedRoutes": []
            },
            "createTeamModalIsOpened": false,
            "editTeamModalIsOpened": false,
            "jumpTeamModalIsOpened": false,
            "popupLoaderShown": false,
            "routeCanvasLoaderShown": false,
            "searchedTeams": [],
            "teamToEdit": {
                "users": [],
                "routes": []
            },
            "validation": {
                "message": "",
                "type":  Constants. validation.types.success.key,
                "isPopup": false
            },
            selectedTeamForConvesser : null,
            defaultConvesserType : {id:4,label:'None',isSelected:true},
            convesserType : [{id:1,label:'MTA',isSelected:false},{id:2,label:'NYPD',isSelected:false},{id:3,label:'Parks',isSelected:false},{id:4,label:'None',isSelected:true}]
            };
