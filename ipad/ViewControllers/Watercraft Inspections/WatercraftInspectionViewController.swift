//
//  WatercraftInspectionViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

// MARK: Ennums
private enum JourneyDetailsSectionRow {
    case Header
    case PreviousWaterBody
    case DestinationWaterBody
    case PreviousMajorCity
    case DestinationMajorCity
    case AddPreviousWaterBody
    case AddDestinationWaterBody
    case PreviousHeader
    case DestinationHeader
    case Divider
}

public enum WatercraftFromSection: Int, CaseIterable {
    case PassportInfo = 0
    case BasicInformation
    case WatercraftDetails
    case JourneyDetails
    case InspectionDetails
    case HighRiskAssessmentFields
    case HighRiskAssessment
    case Divider
    case GeneralComments
}

class WatercraftInspectionViewController: BaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    private let collectionCells = [
        "BasicCollectionViewCell",
        "FormButtonCollectionViewCell",
        "HeaderCollectionViewCell",
        "DividerCollectionViewCell",
        "DestinationWaterBodyCollectionViewCell",
        "PreviousWaterBodyCollectionViewCell",
        "JourneyHeaderCollectionViewCell",
        "PreviousMajorCityCollectionViewCell",
        "DestinationMajorCityCollectionViewCell"
    ]
    
    // MARK: Variables
    var shiftModel: ShiftModel?
    var model: WatercradftInspectionModel? = nil
    private var showFullInspection: Bool = false
    private var showHighRiskAssessment: Bool = false
    private var showFullHighRiskAssessment = false
    private var isEditable: Bool = true
    
    deinit {
        print("De-init inspection")
    }
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        style()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: Setup
    func setup(model: WatercradftInspectionModel) {
        self.model = model
        self.isEditable = model.getStatus() == .Draft
        self.styleNavBar()
        if !model.isPassportHolder || model.launchedOutsideBC || model.isNewPassportIssued {
            self.showFullInspection = true
        }
        
        self.showHighRiskAssessment = shouldShowHighRiskForm()
        self.showFullHighRiskAssessment = shouldShowFullHighRiskForm()
    }
    
    // MARK: High Risk
    func shouldShowHighRiskForm() -> Bool {
        guard let model = self.model else {return false}
        let highRiskFieldKeys = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields().map{ $0.key}
        for key in highRiskFieldKeys {
            if model[key] as? Bool == true {
                return true
            }
        }
        return false
    }
    
    func shouldShowFullHighRiskForm() -> Bool {
        guard let model = self.model, let highRisk = model.highRiskAssessments.first else {return false}
        return !highRisk.cleanDrainDryAfterInspection
    }
    
    func showHighRiskForm(show: Bool) {
        guard let model = self.model else {
            return
        }
        if show && model.highRiskAssessments.isEmpty {
            let _ = model.addHighRiskAssessment()
        }
        self.showHighRiskAssessment = show
        self.showFullHighRiskAssessment = !(model.highRiskAssessments.first?.cleanDrainDryAfterInspection ?? false)
        self.collectionView.reloadData()
    }
    
    func showFullHighRiskForm(show: Bool) {
        showFullHighRiskAssessment = show
        self.collectionView.reloadData()
    }
    
    // MARK: Listeners
    private func addListeners() {
        NotificationCenter.default.removeObserver(self, name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .ShouldResizeInputGroup, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journeyItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldResizeInputGroup(notification:)), name: .ShouldResizeInputGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.journeyItemValueChanged(notification:)), name: .journeyItemValueChanged, object: nil)
    }
    
    private func refreshJourneyDetails(index: Int) {
        
    }
    
    // MARK: Style
    private func style() {
        setNavigationBar(hidden: false, style: UIBarStyle.black)
        self.styleNavBar()
    }
    
    private func styleNavBar() {
        guard let navigation = self.navigationController else { return }
        self.title = "Watercraft Inspection"
        navigation.navigationBar.isTranslucent = false
        navigation.navigationBar.tintColor = .white
        navigation.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        setGradiantBackground(navigationBar: navigation.navigationBar)
        if let model = self.model, model.getStatus() == .Draft {
            setRightNavButtons()
        }
    }
    
    private func setRightNavButtons() {
        let deleteIcon = UIImage(systemName: "trash")
        let deleteButton = UIBarButtonItem(image: deleteIcon,  style: .plain, target: self, action: #selector(self.didTapDeleteButton(sender:)))
        
        let saveIcon = UIImage(systemName: "checkmark")
        let saveButton = UIBarButtonItem(image: saveIcon,  style: .plain, target: self, action: #selector(self.action(sender:)))
        
        navigationItem.rightBarButtonItems = [saveButton, deleteButton]
    }
    
    // Navigation bar right button action
    @objc func didTapDeleteButton(sender: UIBarButtonItem) {
        guard let model = self.model else {return}
        self.dismissKeyboard()
        Alert.show(title: "Deleting Inspection", message: "Would you like to delete this inspection?", yes: {[weak self] in
            guard let _self = self else {return}
            // Delete child objects
            for item in model.previousWaterBodies {
                RealmRequests.deleteObject(item)
            }
            for item in model.destinationWaterBodies {
                RealmRequests.deleteObject(item)
            }
            for item in model.highRiskAssessments {
                RealmRequests.deleteObject(item)
            }
            for item in model.previousMajorCities {
                RealmRequests.deleteObject(item)
            }
            for item in model.destinationMajorCities {
                RealmRequests.deleteObject(item)
            }
            // Delete main object
            RealmRequests.deleteObject(model)
            _self.navigationController?.popViewController(animated: true)
        }) {
            return
        }
    }
    
    @objc func action(sender: UIBarButtonItem) {
        self.dismissKeyboard()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Notification functions
    @objc func shouldResizeInputGroup(notification: Notification) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Input Item Changed
    @objc func inputItemValueChanged(notification: Notification) {
        guard var item: InputItem = notification.object as? InputItem, let model = self.model else {return}
        // Set value in Realm object
        // Keys that need a pop up/ additional actions
        let highRiskFieldKeys = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields().map{ $0.key}
        if highRiskFieldKeys.contains(item.key) {
            let value = item.value.get(type: item.type) as? Bool
            let alreadyHasHighRiskForm = !model.highRiskAssessments.isEmpty
            if value == true && alreadyHasHighRiskForm {
                // set value
                model.set(value: true, for: item.key)
                self.showHighRiskForm(show: true)
            } else if value == true {
                // Show a dialog for high risk form
                let highRiskModal: HighRiskModalView = HighRiskModalView.fromNib()
                highRiskModal.initialize(onSubmit: {
                    // Confirmed
                    model.set(value: true, for: item.key)
                    // Show high risk form
                    self.showHighRiskForm(show: true)
                }) {
                    // Cancelled
                    model.set(value: false, for: item.key)
                    item.value.set(value: false, type: item.type)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: item)
                }
            } else {
                model.set(value: false, for: item.key)
                let shouldShowHighRisk = shouldShowHighRiskForm()
                self.showHighRiskForm(show: shouldShowHighRisk)
                if !shouldShowHighRisk {
                    model.removeHighRiskAssessment()
                }
            }
        } else if
            item.key.lowercased().contains("previousWaterBody".lowercased()) ||
                item.key.lowercased().contains("destinationWaterBody".lowercased())
        {
            // Watercraft Journey
            model.editJourney(inputItemKey: item.key, value: item.value.get(type: item.type) as Any)
        } else if item.key.lowercased().contains("highRisk-".lowercased()) {
            // High Risk Assessment
            model.editHighRiskForm(inputItemKey: item.key, value: item.value.get(type: item.type) as Any)
            if item.key == "highRisk-cleanDrainDryAfterInspection" {
                guard let value = item.value.get(type: .RadioBoolean) as? Bool else {return}
                self.showFullHighRiskForm(show: !value)
            }
        } else if item.key.lowercased() == "countryprovince" {
            // Store directly
            InfoLog("countryProvider Selected: \(item)")
            
            model.set(value: item.value.get(type: item.type) as Any, for: item.key)
            // Now Get code
            guard let dropDown: DropdownInput = item as? DropdownInput else {
                return
            }
            guard let code: CountryProvince = dropDown.getCode() as? CountryProvince else {
                return
            }
            InfoLog("Selected Code: \(code)")
            model.set(value: code.country, for: "countryOfResidence")
            model.set(value: code.province, for: "provinceOfResidence")
        } else {
            // All other keys, store directly
            // TODO: needs cleanup for nil case
            model.set(value: item.value.get(type: item.type) as Any, for: item.key)
        }
        // TODO: CLEANUP
        // Handle Keys that alter form
        if item.key.lowercased() == "isPassportHolder".lowercased() {
            // If is NOT passport holder, Show full form
            let fieldValue = item.value.get(type: item.type) as? Bool ?? nil
            if fieldValue == false {
                self.showFullInspection = true
            } else {
                if model.launchedOutsideBC {
                    self.showFullInspection = true
                } else {
                    self.showFullInspection = false
                }
            }
            self.collectionView.reloadData()
        }
        if item.key.lowercased() == "launchedOutsideBC".lowercased() {
            // If IS passport holder, && launched outside BC, Show full form
            let launchedOutsideBC = item.value.get(type: item.type) as? Bool ?? nil
            if (launchedOutsideBC == true && model.isPassportHolder == true) {
                self.showFullInspection = true
            } else {
                self.showFullInspection = false
            }
            
            self.collectionView.reloadData()
        }
        
        if item.key.lowercased() == "isNewPassportIssued".lowercased() {
            DispatchQueue.main.async {
                let isNewPassportIssued = item.value.get(type: item.type) as? Bool ?? nil
                self.showFullInspection = isNewPassportIssued == true && model.isPassportHolder
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func journeyItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem, let model = self.model else {return}
        model.editJourney(inputItemKey: item.key, value: item.value.get(type: item.type) as Any)
    }
    
    
    func showPDFMap() {
        guard let path = Bundle.main.path(forResource: "pdfMap", ofType: "pdf") else {return}
        unowned let pdfView: PDFViewer = UIView.fromNib()
        let url = URL(fileURLWithPath: path)
        pdfView.initialize(name: "Map",file: url)
    }
    
}

// MARK: CollectionView
extension WatercraftInspectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        for cell in collectionCells {
            register(cell: cell)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func register(cell name: String) {
        guard let collectionView = self.collectionView else {return}
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: name)
    }
    
    func getBasicCell(indexPath: IndexPath) -> BasicCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "BasicCollectionViewCell", for: indexPath as IndexPath) as! BasicCollectionViewCell
    }
    
    func getHeaderCell(indexPath: IndexPath) -> HeaderCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "HeaderCollectionViewCell", for: indexPath as IndexPath) as! HeaderCollectionViewCell
    }
    
    func getButtonCell(indexPath: IndexPath) -> FormButtonCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "FormButtonCollectionViewCell", for: indexPath as IndexPath) as! FormButtonCollectionViewCell
    }
    
    func getDividerCell(indexPath: IndexPath) -> DividerCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DividerCollectionViewCell", for: indexPath as IndexPath) as! DividerCollectionViewCell
    }
    
    func getPreviousWaterBodyCell(indexPath: IndexPath) -> PreviousWaterBodyCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "PreviousWaterBodyCollectionViewCell", for: indexPath as IndexPath) as! PreviousWaterBodyCollectionViewCell
    }
    
    func getDestinationWaterBodyCell(indexPath: IndexPath) -> DestinationWaterBodyCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DestinationWaterBodyCollectionViewCell", for: indexPath as IndexPath) as! DestinationWaterBodyCollectionViewCell
    }
    
    func getPreviousMajorCityCell(indexPath: IndexPath) -> PreviousMajorCityCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "PreviousMajorCityCollectionViewCell", for: indexPath as IndexPath) as!
            PreviousMajorCityCollectionViewCell
    }
    
    func getDestinationMajorCityCell(indexPath: IndexPath) -> DestinationMajorCityCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DestinationMajorCityCollectionViewCell", for: indexPath as IndexPath) as!
            DestinationMajorCityCollectionViewCell
    }
    
    private func arePreviousTogglesChecked(ref: WatercradftInspectionModel) -> Bool {
        if ref.commercialManufacturerAsPreviousWaterBody || ref.unknownPreviousWaterBody || ref.previousDryStorage {
            return true
        } else {
            return false
        }
    }
    
    private func areDestinationTogglesChecked(ref: WatercradftInspectionModel) -> Bool {
        if ref.commercialManufacturerAsDestinationWaterBody || ref.unknownDestinationWaterBody || ref.destinationDryStorage {
            return true
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = WatercraftFromSection(rawValue: Int(section)), let model = self.model else {return 0}
        
        switch sectionType {
        case .JourneyDetails:
            if !arePreviousTogglesChecked(ref: model) && !areDestinationTogglesChecked(ref: model) {
                return model.previousWaterBodies.count + model.destinationWaterBodies.count + 6
            } else if arePreviousTogglesChecked(ref: model) && !areDestinationTogglesChecked(ref: model) {
                return model.previousMajorCities.count + model.destinationWaterBodies.count + 6
            } else if !arePreviousTogglesChecked(ref: model) && areDestinationTogglesChecked(ref: model) {
                return model.previousWaterBodies.count + model.previousMajorCities.count + 6
            } else {
                return model.previousMajorCities.count + model.destinationMajorCities.count + 6
            }
    
        case .HighRiskAssessment:
            if !showHighRiskAssessment {
                return 0
            }
            if self.showFullHighRiskAssessment == true {
                return HighRiskFormSection.allCases.count
            } else {
                return 2
            }
        default:
            return 1
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showFullInspection {
            return WatercraftFromSection.allCases.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = WatercraftFromSection(rawValue: Int(indexPath.section)), let model = self.model else {
            return UICollectionViewCell()
        }
        switch sectionType {
        case .PassportInfo:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Passport Information", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .BasicInformation:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Basic Information", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .WatercraftDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Watercraft Details", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .JourneyDetails:
            return getJourneyDetailsCell(for: indexPath)
        case .InspectionDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Inspection Details", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, showDivider: false, buttonName: "View Map", buttonIcon: "map", onButtonClick: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.showPDFMap()
            })
            return cell
        case .HighRiskAssessmentFields:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "High Risk Assessment Fields", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, boxed: true, showDivider: false)
            return cell
        case .HighRiskAssessment:
            return getHighRiskAssessmentCell(indexPath: indexPath)
        case .GeneralComments:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Comments", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, showDivider: false)
            return cell
        case .Divider:
            let dividerCell = getDividerCell(indexPath: indexPath)
            dividerCell.setup(visible: !showHighRiskAssessment)
            return dividerCell
        }
    }
    
    func getHighRiskAssessmentCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.row)), let model = self.model, let highRiskForm = model.highRiskAssessments.first else {
            return UICollectionViewCell()
        }
        
        let sectionTitle = "\(sectionType)".convertFromCamelCase()
        let cell = getBasicCell(indexPath: indexPath)
        cell.setup(title: sectionTitle, input: highRiskForm.getInputputFields(for: sectionType, editable: isEditable), delegate: self, showDivider: true)
        return cell
    }
    
    func getSizeForHighRiskAssessmentCell(indexPath: IndexPath) -> CGSize {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.row)), let model = self.model, let highRiskForm = model.highRiskAssessments.first else {
            return CGSize()
        }
        
        let estimatedContentHeight = InputGroupView.estimateContentHeight(for: highRiskForm.getInputputFields(for: sectionType))
        return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = WatercraftFromSection(rawValue: Int(indexPath.section)), let model = self.model else {
            return CGSize(width: 0, height: 0)
        }
        switch sectionType {
        case .PassportInfo:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .BasicInformation:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .WatercraftDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .JourneyDetails:
            return estimateJourneyDetailsCellHeight(for: indexPath)
        case .InspectionDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .HighRiskAssessmentFields:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.bounds.width - 16, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .HighRiskAssessment:
            return getSizeForHighRiskAssessmentCell(indexPath: indexPath)
        case .GeneralComments:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .Divider:
            return CGSize(width: self.collectionView.frame.width, height: 30)
        }
    }
    
    @objc private func addPreviousWaterBody(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
        /// ---------waterbody picker------------
        self.setNavigationBar(hidden: true, style: .black)
        let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
        self.viewLayoutMarginsDidChange()
        waterBodyPicker.setup() { (result) in
            print(result)
            for waterBody in result {
                model.addPreviousWaterBody(model: waterBody)
            }
            self.setNavigationBar(hidden: false, style: .black)
            self.viewLayoutMarginsDidChange()
            self.collectionView.reloadData()
        }
    }
    
    @objc private func addPreviousMajorCity(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
        /// ---------nahir city picker------------
        self.setNavigationBar(hidden: true, style: .black)
        let majorCityPicker: MajorCityPicker = UIView.fromNib()
        self.viewLayoutMarginsDidChange()
        majorCityPicker.setup() { (result) in
            print(result)
            for majorCity in result {
                model.setMajorCity(isPrevious: true, majorCity: majorCity)
            }
            self.setNavigationBar(hidden: false, style: .black)
            self.viewLayoutMarginsDidChange()
            self.collectionView.reloadData()
        }
    }
    
    @objc private func addDestinationMajorCity(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
        /// ---------major city picker------------
        self.setNavigationBar(hidden: true, style: .black)
        let majorCityPicker: MajorCityPicker = UIView.fromNib()
        self.viewLayoutMarginsDidChange()
        majorCityPicker.setup() { [weak self] (result) in
            guard let strongerSelf = self else {return}
            print(result)
            for majorCity in result {
                model.setMajorCity(isPrevious: false, majorCity: majorCity)
            }
            strongerSelf.setNavigationBar(hidden: false, style: .black)
            strongerSelf.viewLayoutMarginsDidChange()
            strongerSelf.collectionView.reloadData()
        }
        /// --------------------------------
    }
    
    @objc private func addNextWaterBody(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
        /// ---------waterbody picker------------
        self.setNavigationBar(hidden: true, style: .black)
        let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
        self.viewLayoutMarginsDidChange()
        waterBodyPicker.setup() { [weak self] (result) in
            guard let strongerSelf = self else {return}
            print(result)
            for waterBody in result {
                model.addDestinationWaterBody(model: waterBody)
            }
            strongerSelf.setNavigationBar(hidden: false, style: .black)
            strongerSelf.viewLayoutMarginsDidChange()
            strongerSelf.collectionView.reloadData()
        }
        /// --------------------------------
    }
    
    // Reload Journey Details section
    private func reloadJourneyDetailSection(indexPath: IndexPath) {
        self.collectionView.performBatchUpdates({
            self.collectionView?.reloadSections(IndexSet(integer: indexPath.section))
        }, completion: nil)

    }
    
    private func getJourneyDetailsCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = self.model else {return UICollectionViewCell()}
        switch getJourneyDetailsCellType(for: indexPath) {
        case .Header:
            let cell = getHeaderCell(indexPath: indexPath)
            cell.setup(with: "Journey Details")
            return cell
        case .PreviousWaterBody:
            let cell = getPreviousWaterBodyCell(indexPath: indexPath)
            let itemsIndex: Int = indexPath.row - 2
            let previousWaterBody = model.previousWaterBodies[itemsIndex]
            cell.setup(with: previousWaterBody, isEditable: self.isEditable, input: model.getPreviousWaterBodyInputFields(for: .JourneyDetails, editable: isEditable, index: itemsIndex),  delegate: self, onDelete: { [weak self] in
                guard let strongSelf = self else {return}
                model.removePreviousWaterBody(at: itemsIndex)
                strongSelf.collectionView.performBatchUpdates({
                    strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            return cell
        case .DestinationWaterBody:
            let cell = getDestinationWaterBodyCell(indexPath: indexPath)
            var itemsIndex: Int = 0
            if arePreviousTogglesChecked(ref: model) {
                itemsIndex = indexPath.row - (model.previousMajorCities.count + 4)
            } else {
                itemsIndex = indexPath.row - (model.previousWaterBodies.count + 4)
            }
            let destinationWaterBody = model.destinationWaterBodies[itemsIndex]
            cell.setup(with: destinationWaterBody, isEditable: self.isEditable, delegate: self, onDelete: { [weak self] in
                guard let strongSelf = self else {return}
                model.removeDestinationWaterBody(at: itemsIndex)
                strongSelf.collectionView.performBatchUpdates({
                    strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            return cell
        
        case .PreviousMajorCity:
            let cell = getPreviousMajorCityCell(indexPath: indexPath)
            let itemsIndex: Int = 0
            let previousMajorCity = model.previousMajorCities[itemsIndex]
            cell.setup(with: previousMajorCity, isEditable: self.isEditable, delegate: self, onDelete: { [weak self] in
                guard let strongSelf = self else {return}
                model.deleteMajorCity(isPrevious: true)
                strongSelf.collectionView.performBatchUpdates({
                    strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            
            return cell
        
        case .DestinationMajorCity:
            let cell = getDestinationMajorCityCell(indexPath: indexPath)
            let itemsIndex: Int = 0
            let destinationMajorCity = model.destinationMajorCities[itemsIndex]
            cell.setup(with: destinationMajorCity, isEditable: self.isEditable, delegate: self, onDelete: { [weak self] in
                guard let strongSelf = self else {return}
                model.deleteMajorCity(isPrevious: false)
                strongSelf.collectionView.performBatchUpdates({
                    strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            
            return cell
        case .AddPreviousWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(
                with: "Add Previous Water Body",
                isEnabled: isEditable,
                config: FormButtonCollectionViewCell.Config(
                    status: self.model?.previousDryStorage ?? false,
                    unknownWaterBodyStatus: self.model?.unknownPreviousWaterBody ?? false,
                    commercialManufacturerStatus: self.model?.commercialManufacturerAsPreviousWaterBody ?? false,
                    isPreviousJourney: true,
                    displaySwitch: true,
                    displayUnknowSwitch: true)
            ) { [weak self] action in
                guard let strongSelf = self else {return}
                /// ----- Switch Action ------
                switch action {
                case .statusChange(let result):
                    InfoLog("User change status: \(result) of previous water body")
                    strongSelf.model?.setJournyStatusFlags(dryStorage: result.dryStorgae, unknown: result.unknown, commercialManufacturer: result.commercialManufacturer, isPrevious: true)
                    strongSelf.reloadJourneyDetailSection(indexPath: indexPath)
                case .add:
                    /// ---------waterbody picker------------
                    InfoLog("User want to add previous water body")
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    waterBodyPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        for waterBody in result {
                            model.addPreviousWaterBody(model: waterBody)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                        waterBodyPicker.removeFromSuperview()
                    }
                case .addMajorCity:
                    /// ---------major city picker------------
                    InfoLog("User want to add previous major city")
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let majorCityPicker: MajorCityPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    majorCityPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        for majorCity in result {
                            model.setMajorCity(isPrevious: true, majorCity: majorCity)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                        majorCityPicker.removeFromSuperview()
                    }
                    
                    /// --------------------------------
                }
            }
            return cell
        case .AddDestinationWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(
                with: "Add Destination Water Body",
                isEnabled: isEditable,
                config: FormButtonCollectionViewCell.Config(
                    status: self.model?.destinationDryStorage ?? false,
                    unknownWaterBodyStatus: self.model?.unknownDestinationWaterBody ?? false,
                    commercialManufacturerStatus: self.model?.commercialManufacturerAsDestinationWaterBody ?? false,
                    isPreviousJourney: false,
                    displaySwitch: true,
                    displayUnknowSwitch: true)
            ) { [weak self] action in
                
                guard let strongSelf = self else {return}
                /// ----- Switch Action ------
                switch action {
                case .statusChange(let result):
                    InfoLog("User change status: \(result) of destination water body")
                    strongSelf.model?.setJournyStatusFlags(dryStorage: result.dryStorgae, unknown: result.unknown, commercialManufacturer: result.commercialManufacturer, isPrevious: false)
                    strongSelf.reloadJourneyDetailSection(indexPath: indexPath)
                case .add:
                    /// ---------waterbody picker------------
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    waterBodyPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        print(result)
                        for waterBody in result {
                            model.addDestinationWaterBody(model: waterBody)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                    }
                case .addMajorCity:
                    /// ---------waterbody picker------------
                    InfoLog("User want to add destination major city")
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let majorCityPicker: MajorCityPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    majorCityPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        for majorCity in result {
                            model.setMajorCity(isPrevious: false, majorCity: majorCity)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                        majorCityPicker.removeFromSuperview()
                    }
                    /// --------------------------------
                }
            }
            return cell
        case .Divider:
            let dividerCell = getDividerCell(indexPath: indexPath)
            dividerCell.setup(visible: true)
            return dividerCell
        case .PreviousHeader:
            let cell = getHeaderCell(indexPath: indexPath)
            cell.setup(with: "Previous Waterbody")
            return cell
        case .DestinationHeader:
            let cell = getHeaderCell(indexPath: indexPath)
            cell.setup(with: "Destination Waterbody")
            return cell
        }
    }
    
    private func estimateJourneyDetailsCellHeight(for indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        switch getJourneyDetailsCellType(for: indexPath) {
        case .Header:
            return CGSize(width: width, height: 50)
        case .PreviousMajorCity:
            return CGSize(width: width, height: 200)
        case .DestinationMajorCity:
            return CGSize(width: width, height: 200)
        case .PreviousWaterBody:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: WatercraftInspectionFormHelper.getPreviousWaterBodyFields(index: 0))
            return CGSize(width: width, height: estimatedContentHeight + 20)
        case .DestinationWaterBody:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: WatercraftInspectionFormHelper.watercraftInspectionDestinationWaterBodyInputs(index: 0))
            return CGSize(width: width, height: estimatedContentHeight + 20)
        case .AddPreviousWaterBody:
            return CGSize(width: width, height: 110)
        case .AddDestinationWaterBody:
            return CGSize(width: width, height: 110)
        case .Divider:
            return CGSize(width: width, height: 10)
        case .PreviousHeader:
            return CGSize(width: width, height: 50)
        case .DestinationHeader:
            return CGSize(width: width, height: 50)
        }
    }
    
    private func getJourneyDetailsCellType(for indexPath: IndexPath) -> JourneyDetailsSectionRow {
        guard let model = self.model else {return .Divider}
        if indexPath.row == 0 {
            return .Header
        }
        
        if indexPath.row ==  1 {
            return .PreviousHeader
        }
        
        if arePreviousTogglesChecked(ref: model)  {
            if indexPath.row == model.previousMajorCities.count + 2 {
                return .AddPreviousWaterBody
            }
            
            if indexPath.row == model.previousMajorCities.count + 3 {
                return .DestinationHeader
            }

            if indexPath.row <= model.previousMajorCities.count + 3 {
                return .PreviousMajorCity
            }
        } else {
            if indexPath.row == model.previousWaterBodies.count + 2 {
                return .AddPreviousWaterBody
            }
            if indexPath.row == model.previousWaterBodies.count + 3 {
                return .DestinationHeader
            }
            if indexPath.row <= model.previousWaterBodies.count + 3 {
                return .PreviousWaterBody
            }
        }
        
        if areDestinationTogglesChecked(ref: model) && arePreviousTogglesChecked(ref: model) {
            if indexPath.row <= (model.previousMajorCities.count + model.destinationMajorCities.count + 3) {
                return .DestinationMajorCity
            }
            if indexPath.row == model.previousMajorCities.count + model.destinationMajorCities.count + 4 {
                return .AddDestinationWaterBody
            }
        }
        else if areDestinationTogglesChecked(ref: model) && !arePreviousTogglesChecked(ref: model) {
            if indexPath.row <= (model.previousWaterBodies.count + model.destinationMajorCities.count + 3) {
                return .DestinationMajorCity
            }
            if indexPath.row == model.previousWaterBodies.count + model.destinationMajorCities.count + 4 {
                return .AddDestinationWaterBody
            }
        }
        else if !areDestinationTogglesChecked(ref: model) && arePreviousTogglesChecked(ref: model) {
            if indexPath.row <= (model.previousMajorCities.count + model.destinationWaterBodies.count + 3) {
                return .DestinationWaterBody
            }
            if indexPath.row == model.previousMajorCities.count + model.destinationWaterBodies.count + 4 {
                return .AddDestinationWaterBody
            }
        }
        else {
            model.deleteMajorCity(isPrevious: false)
            model.deleteMajorCity(isPrevious: true)
            if indexPath.row == model.previousWaterBodies.count + model.destinationWaterBodies.count + 4 {
                return .AddDestinationWaterBody
            }
            
            if indexPath.row <= (model.previousWaterBodies.count + model.destinationWaterBodies.count + 3) {
                return .DestinationWaterBody
            }
        }
        
        return .Divider
    }
}
