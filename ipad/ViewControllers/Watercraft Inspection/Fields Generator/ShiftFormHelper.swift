//
//  ShiftFormHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

class ShiftFormHelper {
    
    static func getShiftStartFields(for object: ShiftModel? = nil, editable: Bool? = true, modalSize: Bool? = false) -> [InputItem] {
        let isModalSize = modalSize ?? false
        var sectionItems: [InputItem] = []
        
        let startTime = TimeInput(
            key: "startTime",
            header: ShiftFormHeaders.ShiftStart.startTime,
            editable: editable ?? true,
            value: object?.startTime ?? "",
            width: .Half
        )
        sectionItems.append(startTime)
        
        let station = DropdownInput(
            key: "station",
            header: ShiftFormHeaders.ShiftStart.station,
            editable: editable ?? true,
            value: object?.station,
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .stations)
        )
        sectionItems.append(station)
        
        let sunny = RadioBoolean(
            key: "sunny",
            header: ShiftFormHeaders.ShiftStart.sunny,
            editable: editable ?? true,
            value: object?.sunny,
            width: .Third 
        )
        sectionItems.append(sunny)
        
        let cloudy = RadioBoolean(
            key: "cloudy",
            header: ShiftFormHeaders.ShiftStart.cloudy,
            editable: editable ?? true,
            value: object?.cloudy,
            width: .Third
        )
        sectionItems.append(cloudy)
        
        let raining = RadioBoolean(
            key: "raining",
            header: ShiftFormHeaders.ShiftStart.raining,
            editable: editable ?? true,
            value: object?.raining,
            width: .Third
        )
        sectionItems.append(raining)
        
        let snowing = RadioBoolean(
            key: "snowing",
            header: ShiftFormHeaders.ShiftStart.snowing,
            editable: editable ?? true,
            value: object?.snowing,
            width: .Third
        )
        sectionItems.append(snowing)
        
        let foggy = RadioBoolean(
            key: "foggy",
            header: ShiftFormHeaders.ShiftStart.foggy,
            editable: editable ?? true,
            value: object?.foggy,
            width: .Third
        )
        sectionItems.append(foggy)
        
        let windy = RadioBoolean(
            key: "windy",
            header: ShiftFormHeaders.ShiftStart.windy,
            editable: editable ?? true,
            value: object?.windy,
            width: .Third
        )
        sectionItems.append(windy)
        
        let shitStartComments = TextAreaInput(
            key: "shitStartComments",
            header: ShiftFormHeaders.ShiftStart.comments,
            editable: editable ?? true,
            value: object?.shitStartComments ?? "",
            width: .Full
        )
        sectionItems.append(shitStartComments)
        
        print(sectionItems.count)
        
        return sectionItems
    }
    
    static func getShiftEndFields(for object: ShiftModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        let endTime = TimeInput(
            key: "endTime",
            header: ShiftFormHeaders.ShiftEnd.endTime,
            editable: editable ?? true,
            value: object?.endTime ?? "",
            width: .Third
        )
        sectionItems.append(endTime)
        
        let k9OnShift = SwitchInput(
            key: "k9OnShif",
            header: ShiftFormHeaders.ShiftStart.k9OnShift,
            editable: editable ?? true,
            value: object?.k9OnShif,
            width: .Third
        )
        sectionItems.append(k9OnShift)
        
        let boatsInspected = SwitchInput(
            key: "boatsInspected",
            header: ShiftFormHeaders.ShiftEnd.boatsInspected,
            editable: editable ?? true,
            value: object?.boatsInspected,
            width: .Third
        )
        sectionItems.append(boatsInspected)
        
        let motorizedBlowBys = IntegerStepperInput(
            key: "motorizedBlowBys",
            header: ShiftFormHeaders.ShiftEnd.motorizedBlowBys,
            editable: editable ?? true,
            value: object?.motorizedBlowBys,
            width: .Third
        )
        sectionItems.append(motorizedBlowBys)
        
        let nonMotorizedBlowBys = IntegerStepperInput(
            key: "nonMotorizedBlowBys",
            header: ShiftFormHeaders.ShiftEnd.nonMotorizedBlowBys,
            editable: editable ?? true,
            value: object?.nonMotorizedBlowBys,
            width: .Third
        )
        sectionItems.append(nonMotorizedBlowBys)
        
        let spacer = InputSpacer()
        sectionItems.append(spacer)
        
        let shitEndComments = TextAreaInput(
            key: "shitEndComments",
            header: ShiftFormHeaders.ShiftEnd.comments,
            editable: editable ?? true,
            value: object?.shitEndComments ?? "",
            width: .Full
        )
        sectionItems.append(shitEndComments)
        
         print(sectionItems.count)
        
        return sectionItems
    }
    
    func getTableColumns() -> [TableViewColumnConfig] {
        // Create Column Config
        var columns: [TableViewColumnConfig] = []
        columns.append(TableViewColumnConfig(key: "remoteId", header: "Shift ID", type: .Normal))
        columns.append(TableViewColumnConfig(key: "riskLevel", header: "Shift Date", type: .Normal))
        columns.append(TableViewColumnConfig(key: "timeAdded", header: "Station Location", type: .Normal))
        columns.append(TableViewColumnConfig(key: "status", header: "Status", type: .WithIcon))
        columns.append(TableViewColumnConfig(key: "", header: "Actions", type: .Button, buttonName: "View", showHeader: false))
        return columns
    }
    
}
