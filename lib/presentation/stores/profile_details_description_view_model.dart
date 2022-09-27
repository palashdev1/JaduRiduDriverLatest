

import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

import '../../core/common/alert_action.dart';
import '../../core/common/alert_behaviour.dart';
import '../../core/common/alert_data.dart';
import '../../core/common/alert_option.dart';
import '../../core/common/current_date_time.dart';
import '../../core/common/dialog_state.dart';
import '../../core/common/gender_radio_button.dart';
import '../../core/common/response.dart';
import '../../core/domain/mobile_number_code.dart';
import '../../core/domain/package.dart';
import '../../core/repository/welcome_jadu_ride_repository.dart';
import '../../helpers_impls/date_time_helper.dart';
import '../../modules/app_module.dart';
import '../../utills/dialog_manager.dart';
import 'package:jadu_ride_driver/core/helpers/storage.dart';

import '../../utills/my_utils.dart';
import '../ui/string_provider.dart';
import '../ui/theme.dart';
import 'dart:io';
part 'profile_details_description_view_model.g.dart';

class ProfileDescriptionStore = _ProfileDescriptionViewModel with _$ProfileDescriptionStore;

abstract class _ProfileDescriptionViewModel with Store{

  final _repository = dependency<WelcomeJaduRideRepository>();
  final _storage = dependency<Storage>();
  final dialogManager = DialogManager();
  late final ImagePicker _picker;
  late final ImageCropper _cropper;
  final _dateTimeHelper = DateTimeHelper();

  @observable
  bool gettingLoader = false;

  @observable
  String userMobileNumber = "";

  @observable
  List<Package> states = [];

  @observable
  List<Package> districts = [];

  @observable
  List<Package> cities = [];

  @observable
  List<MobileNumberCode> codes = [];

  @observable
  MobileNumberCode? selectedCode;

  @observable
  Package? selectedDistrict;

  @observable
  Package? selectedState;

  @observable
  Package? selectedCity;

  @observable
  bool gettingDistrictsLoader = false;

  @observable
  bool gettingCitiesLoader = false;

  @observable
  String userName = "";

  @observable
  String userEmail = "";

  @observable
  String referralCode = "";

  @observable
  bool isTermsSelected = false;

  @observable
  bool enableBtn = false;

  @observable
  bool uploadingLoader = false;

  _ProfileDescriptionViewModel() {
    _initialData();
    _validateInputs();
    _picker = ImagePicker();
    _cropper = ImageCropper();
  }

  @action
  _initialData() async {
    gettingLoader = true;
    var userId = _storage.userId();
    var response = await _repository.getInitialData(userId);
    if (response is Success) {
      var data = response.data;
      gettingLoader = false;
      switch (data != null && data.status) {
        case true:
          userMobileNumber = data!.mobileNumber;
          states = data.states;
          codes = data.numberCodes;
          selectedCode = data.numberCodes.first;
          selectedState = data.states.first;
          break;
        default:
          dialogManager.initErrorData(AlertData(
              StringProvider.error,
              null,
              StringProvider.appId,
              data?.message ?? "",
              StringProvider.retry,
              null,
              null,
              AlertBehaviour(
                  option: AlertOption.invokeOnBarrier,
                  action: AlertAction.welcomeJaduRideInitialData)));
      }
    } else if (response is Error) {
      gettingLoader = false;
      dialogManager.initErrorData(AlertData(
          StringProvider.error,
          null,
          StringProvider.appId,
          response.message ?? "",
          StringProvider.retry,
          null,
          null,
          AlertBehaviour(
              option: AlertOption.invokeOnBarrier,
              action: AlertAction.welcomeJaduRideInitialData)));
    }
  }

  @action
  getDistricts() async {
    gettingDistrictsLoader = true;
    var response = await _repository.districts(selectedState!.id);
    if (response is Success) {
      var data = response.data;
      gettingDistrictsLoader = false;
      switch (data != null && data.status) {
        case true:
          districts = data!.districts;
          selectedDistrict = data.districts.first;
          break;
        default:
          dialogManager.initErrorData(AlertData(
              StringProvider.error,
              null,
              StringProvider.appId,
              data?.message ?? "",
              StringProvider.retry,
              null,
              null,
              AlertBehaviour(
                  option: AlertOption.invokeOnBarrier,
                  action: AlertAction.getDistricts)));
      }
    } else if (response is Error) {
      gettingDistrictsLoader = false;
      dialogManager.initErrorData(AlertData(
          StringProvider.error,
          null,
          StringProvider.appId,
          response.message ?? "",
          StringProvider.retry,
          null,
          null,
          AlertBehaviour(
              option: AlertOption.invokeOnBarrier,
              action: AlertAction.getDistricts)));
    }
  }

  @action
  getCities() async {
    gettingCitiesLoader = true;
    var response = await _repository.cities(selectedDistrict!.id);
    if (response is Success) {
      var data = response.data;
      gettingCitiesLoader = false;
      switch (data != null && data.status) {
        case true:
          cities = data!.cities;
          selectedCity = data.cities.first;
          break;
        default:
          dialogManager.initErrorData(AlertData(
              StringProvider.error,
              null,
              StringProvider.appId,
              data?.message ?? "",
              StringProvider.retry,
              null,
              null,
              AlertBehaviour(
                  option: AlertOption.invokeOnBarrier,
                  action: AlertAction.getCities)));
      }
    } else if (response is Error) {
      gettingCitiesLoader = false;
      dialogManager.initErrorData(AlertData(
          StringProvider.error,
          null,
          StringProvider.appId,
          response.message ?? "",
          StringProvider.retry,
          null,
          null,
          AlertBehaviour(
              option: AlertOption.invokeOnBarrier,
              action: AlertAction.getCities)));
    }
  }

  @action
  name(String value) {
    userName = value;
  }

  @action
  email(String value) {
    userEmail = value;
  }

  @action
  mobileNumber(String number) {
    userMobileNumber = number;
  }

  @action
  mobileNumberCleared() {
    userMobileNumber = "";
  }

  @action
  onNumberCode(MobileNumberCode? code) {
    selectedCode = code;
  }

  @action
  onReferralCode(String code) {
    referralCode = code;
  }

  @action
  termsConditionClicked() {
    isTermsSelected = !isTermsSelected;
  }

  @action
  onState(Package? state) {
    selectedState = state;
  }

  @action
  onDistrict(Package? district) {
    selectedDistrict = district;
  }

  @action
  onCity(Package? city) {
    selectedCity = city;
  }

  @action
  _validateInputs() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (userName.isEmpty) {
        enableBtn = false;
      } else if (referralCode.isEmpty) {
        enableBtn = false;
      } else if (userMobileNumber.isEmpty) {
        enableBtn = false;
      } else if (!isTermsSelected) {
        enableBtn = false;
      } else {
        enableBtn = true;
      }
    }
  }

  onRetry(AlertAction? action) {
    switch (action) {
      case AlertAction.welcomeJaduRideInitialData:
        _initialData();
        break;
      case AlertAction.getDistricts:
        getDistricts();
        break;
      case AlertAction.getCities:
        getCities();
        break;
      case AlertAction.uploadUserData:
        onContinue();
        break;
      case AlertAction.none:
        debugPrint("action is $action");
        break;
      default:
        debugPrint("action is $action");
    }
  }

  @action
  onContinue() async {
    uploadingLoader = true;
    var userId = _storage.userId();
    var response = await _repository.sendUserData(
        userId,
        userName,
        userEmail,
        userMobileNumber,
        selectedState?.id ?? "",
        selectedDistrict?.id ?? "",
        selectedCity?.id ?? "",
        referralCode,
        isTermsSelected);

    /*if (response is Success) {
      var data = response.data;
      uploadingLoader = false;
      switch (data != null && data.status) {
        case true:
          if (data!.isSaved) {
            _storage.saveUserName(userName);
            //onChange(ScreenWithExtras(
              //screen: Screen.addVehicle,
            ));
          } else {
            dialogManager.initErrorData(AlertData(
                StringProvider.error,
                null,
                StringProvider.appId,
                data.message,
                StringProvider.okay,
                null,
                null,
                AlertBehaviour(
                    option: AlertOption.none, action: AlertAction.none)));
          }
          break;
        default:
          dialogManager.initErrorData(AlertData(
              StringProvider.error,
              null,
              StringProvider.appId,
              data?.message ?? "",
              StringProvider.retry,
              null,
              null,
              AlertBehaviour(
                  option: AlertOption.none,
                  action: AlertAction.uploadUserData)));
      }
    } else if (response is Error) {
      uploadingLoader = false;
      dialogManager.initErrorData(AlertData(
          StringProvider.error,
          null,
          StringProvider.appId,
          response.message ?? "",
          StringProvider.retry,
          null,
          null,
          AlertBehaviour(
              option: AlertOption.none, action: AlertAction.uploadUserData)));
    }*/
  }


  @observable
  String informMessage = "";

  @observable
  DialogState openImagePicker = DialogState.notDisplaying;

  @observable
  File? selectedImage;

  @observable
  String selectedGender = "";

  @action
  selectImage() {
    openImagePicker = DialogState.displaying;
  }

  @action
  chooseFromCamera() async {
    var image =
    await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (image != null) {
      var croppedImage = await _cropImage(image);
      if (croppedImage != null) {
        selectedImage = File(croppedImage.path);
        debugPrint(
            "selected from camera: ${selectedImage?.path} mime type: ${selectedImage?.absolute}");
      }
    } else {
      debugPrint("image not chosen");
    }
  }

  @observable
  GenderRadio selected = GenderRadio.none;

  @observable
  String finalCurrentDate = "";

  /*@action
  currentDate() {
    finalCurrentDate = GetDateState.getCurrentDate();
  }*/

  @action
  onRadioSelected(GenderRadio? selectedValue) {
    if (selectedValue == null) {
      selected = GenderRadio.none;
    } else {
      selected = selectedValue;
      if(selected.name=="male"){
        selectedGender = "male";
      }else if(selected.name=="female"){
        selectedGender = "female";
      }else{
        selectedGender = "none";
      }
    }
    //MyUtils.toastMessage(selectedGender);
  }

  @action
  chooseFromGallery() async {
    var image =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      var croppedImage = await _cropImage(image);
      if (croppedImage != null) {
        selectedImage = File(croppedImage.path);
        debugPrint(
            "selected from gallery: ${selectedImage?.path} mime type: ${selectedImage?.absolute}");
      }
    } else {
      debugPrint("image not chosen");
    }
  }

  @action
  onClose() {
    openImagePicker = DialogState.notDisplaying;
  }

  Future<CroppedFile?> _cropImage(XFile image) async {
    return await _cropper
        .cropImage(sourcePath: image.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ], uiSettings: [
      AndroidUiSettings(
        statusBarColor: AppColors.primary,
        toolbarTitle: StringProvider.crop,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        aspectRatioLockEnabled: false,
        title: StringProvider.crop,
      )
    ]);
  }

  openDatePicker() {
    dialogManager.openDatePicker();
  }

  @action
  onSelectDate(DateTime? selected) {
    if (selected != null) {
      finalCurrentDate = "${selected.day} ${_dateTimeHelper.getMonthName(selected.month)}, ${selected.year}";
      //finalCurrentDate = "${selected.day}-${selected.month}-${selected.year}";
      //MyUtils.toastMessage("hahaha");

    } else {
      //currentDate();
      finalCurrentDate = "25th june 1998";
    }
  }

  @action
  clearImage() {
    selectedImage = null;
  }

  /*@action
  onDone() async {
    var userId = _storage.userId();
    var response =
    await _repository.uploadImage(userId, selectedImage!, uploader.start);
    if (response is Success) {
      var data = response.data;

      switch (data != null && data.status) {
        case true:
          if (data!.isUploaded) {
            informMessage = data.message;
            onChange(ScreenWithExtras(
                screen: Screen.addAllDetails, argument: data.isUploaded));
          } else {
            dialogManager.initErrorData(AlertData(
                StringProvider.error,
                null,
                StringProvider.appId,
                data.message,
                StringProvider.retry,
                null,
                null,
                AlertBehaviour(
                    option: AlertOption.none,
                    action: AlertAction.uploadProfileImage)));
          }
          break;
        default:
          dialogManager.initErrorData(AlertData(
              StringProvider.error,
              null,
              StringProvider.appId,
              data?.message ?? "",
              StringProvider.retry,
              null,
              null,
              AlertBehaviour(
                  option: AlertOption.none,
                  action: AlertAction.uploadProfileImage)));
      }
    } else if (response is Error) {
      dialogManager.initErrorData(AlertData(
          StringProvider.error,
          null,
          StringProvider.appId,
          response.message ?? "",
          StringProvider.retry,
          null,
          null,
          AlertBehaviour(
              option: AlertOption.invokeOnBarrier,
              action: AlertAction.uploadProfileImage)));
    }
  }*/

  onError(AlertAction? action) {
    if (action == AlertAction.uploadProfileImage) {
      //onDone();
    }
  }


}