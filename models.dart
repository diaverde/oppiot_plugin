// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

/* ----------------Models------------
Contiene las clases que se utilizan para recibir los diferentes
datos consultados
*/
import 'dart:convert';
import 'dart:io';

import 'package:chainway_r6_client_functions/chainway_r6_client_functions.dart'
    as r6_plugin;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:postek_plugin/postek_plugin.dart';
import 'package:gs1/asset_code.dart';

// Para generación de json_serializable
part 'models.g.dart';

// -----------------------------------------Asset y asociadas-----------------------------------
/// Clase Asset
@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class Asset {
  /// Constructor
  Asset(
      {this.id,
      this.assetCode,
      this.assetCodeLegacy,
      this.companyCode,
      this.locationName,
      this.name,
      this.description,
      this.categories,
      this.assetDetails,
      this.custody,
      this.status,
      this.lastStocktaking,
      this.images});

  /// ID en base de datos
  String id;

  /// Código EPC del activo
  String assetCode;

  /// Código antiguo del activo
  LegacyCode assetCodeLegacy;

  /// Identificador de la empresa
  String companyCode;

  /// Sede de ubicación del activo
  String locationName;

  /// Nombre del activo
  String name;

  /// Descripción del activo
  String description;

  /// Categoría del activo 1
  List<AssetCategory> categories;

  /// Detalles del activo
  AssetDetails assetDetails;

  /// Custodia
  String custody;

  /// Estado actual
  String status;

  /// Lista de fotos
  List<AssetPhoto> images;

  ///ultimo stock asociado al asset
  Map<String, String> lastStocktaking;

  /// Convertir de json a clase
  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetToJson(this);

  /// Crear copia del activo
  Asset copy() => Asset(
      id: id,
      assetCode: assetCode,
      assetCodeLegacy: assetCodeLegacy,
      companyCode: companyCode,
      locationName: locationName,
      name: name,
      description: description,
      categories: categories,
      assetDetails: assetDetails,
      custody: custody,
      status: status,
      lastStocktaking: lastStocktaking,
      images: images);
}

/// Clase LegacyCode, para el código antiguo del activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class LegacyCode {
  /// Constructor
  LegacyCode({this.system, this.value});

  /// Sistema de información
  String system;

  /// Valor del código
  String value;

  factory LegacyCode.fromJson(Map<String, dynamic> json) =>
      _$LegacyCodeFromJson(json);

  Map<String, dynamic> toJson() => _$LegacyCodeToJson(this);
}

/// Clase Category, para categorizar el activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetCategory {
  /// Constructor
  AssetCategory({this.name, this.value});

  /// Nombre de la categoría
  String name;

  /// Valor del campo
  String value;

  factory AssetCategory.fromJson(Map<String, dynamic> json) =>
      _$AssetCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$AssetCategoryToJson(this);
}

/// contiene los asset perdidos
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetMissign {
  AssetMissign(
      {this.totalAssets,
      this.missingAssets,
      this.lastInventory,
      this.totalLocations,
      this.listMissingAsset});
  final String totalAssets;
  final String missingAssets;
  final String lastInventory;
  final String totalLocations;
  final List<Asset> listMissingAsset;

  factory AssetMissign.fromJson(Map<String, dynamic> json) =>
      _$AssetMissignFromJson(json);

  Map<String, dynamic> toJson() => _$AssetMissignToJson(this);
}

/// Clase AssetDetails, para detalles del activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetDetails {
  /// Constructor
  AssetDetails({this.model, this.serialNumber, this.make});

  /// Modelo
  String model;

  /// Número serial
  String serialNumber;

  /// Fabricante
  String make;

  factory AssetDetails.fromJson(Map<String, dynamic> json) =>
      _$AssetDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDetailsToJson(this);
}

/// Clase AssetImage, para las imágenes del activo
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetPhoto {
  /// Constructor
  AssetPhoto({this.picture, this.author, this.date});

  /// Ruta de la imagen
  String picture;

  /// Autor de la imagen
  String author;

  /// Fecha de la imagen
  String date;

  factory AssetPhoto.fromJson(Map<String, dynamic> json) =>
      _$AssetPhotoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetPhotoToJson(this);
}

/// Clase AssetRead para procesar los activos leídos en el conteo
class AssetRead {
  /// Constructor
  AssetRead({this.assetCode, this.location, this.name, this.found});

  /// Código del activo
  String assetCode;

  /// Sede
  String location;

  /// Nombre
  String name;

  /// Estado después del conteo
  bool found;
}

/// Clase JsonAssetList para extraer activos que vienen como lista en un json
@JsonSerializable(fieldRename: FieldRename.pascal)
class JsonAssetList {
  /// Constructor
  JsonAssetList({this.assetsList});

  /// Lista de activos capturada en json
  List assetsList;

  /// Convertir de json a clase
  factory JsonAssetList.fromJson(Map<String, dynamic> json) =>
      _$JsonAssetListFromJson(json);

  Map<String, dynamic> toJson() => _$JsonAssetListToJson(this);
}

// -----------------------------------------Stocktaking y asociadas-----------------------------------
/// Clase Stocktaking
@JsonSerializable(fieldRename: FieldRename.pascal)
class Stocktaking {
  /// Constructor
  Stocktaking(
      {this.id,
      this.companyCode,
      this.locationName,
      this.timeStamp,
      this.userName,
      this.origin,
      this.assets});

  /// ID en base de datos
  @JsonKey(ignore: true)
  String id;

  /// Identificador de la empresa
  String companyCode;

  /// Sede
  String locationName;

  /// Estampa de tiempo
  String timeStamp;

  /// Usuario que hizo el conteo
  String userName;

  /// Origen del conteo
  String origin;

  /// Lista de activos encontrados
  List assets;

  /// Convertir de json a clase
  factory Stocktaking.fromJson(Map<String, dynamic> json) =>
      _$StocktakingFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$StocktakingToJson(this);
}

/// Clase AssetStatus para procesar los activos leídos
/// en el conteo para enviar en el reporte
@JsonSerializable(fieldRename: FieldRename.pascal)
class AssetStatus {
  /// Constructor
  AssetStatus({this.assetId, this.findStatus});

  /// Código del activo
  String assetId;

  /// Estado del activo después del conteo
  String findStatus;

  /// Convertir de json a clase
  factory AssetStatus.fromJson(Map<String, dynamic> json) =>
      _$AssetStatusFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$AssetStatusToJson(this);
}

// -----------------------------------------User y asociadas-----------------------------------
/// Clase User
@JsonSerializable(explicitToJson: true)
class User {
  /// Constructor
  User(
      {this.id,
      this.userName,
      this.name,
      this.externalId,
      this.password,
      this.photos,
      this.emails,
      this.active,
      this.organization,
      this.idOrganization,
      this.roles,
      this.helpScreens});

  /// ID en base de datos
  @JsonKey(name: 'id')
  String id;

  /// Nombre virtual de usuario
  String userName;

  /// Nombres del usuario
  Name name;

  /// Documento de identidad
  String externalId;

  /// Contraseña del usuario
  String password;

  /// Fotos del usuario
  List<Photo> photos;

  /// Correos del usuario
  List<Email> emails;

  /// ¿Está activo?
  bool active;

  /// Empresa
  String organization;

  /// ID Empresa
  String idOrganization;

  /// Roles
  List<String> roles;

  /// Lista de pantallas de ayuda
  List<HelpScreen> helpScreens;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// `toJson` is the convention for a class to declare support for
  /// serialization to JSON. The implementation simply calls the private,
  /// generated helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Crear copia del activo
  User copy() => User(
        id: id,
        userName: userName,
        name: name,
        externalId: externalId,
        password: password,
        photos: photos,
        emails: emails,
        active: active,
        organization: organization,
        idOrganization: idOrganization,
        roles: roles,
        helpScreens: helpScreens,
      );
}

/// Clase Name, para los nombres de usuario
@JsonSerializable()
class Name {
  /// Constructor
  Name(
      {this.givenName,
      this.middleName,
      this.familyName,
      this.additionalFamilyNames});

  /// Nombre inicial del usuario
  String givenName;

  /// Nombres secundarios
  String middleName;

  /// Apellido
  String familyName;

  /// Otros apellidos
  String additionalFamilyNames;

  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);

  Map<String, dynamic> toJson() => _$NameToJson(this);
}

/// Clase Photo, para las imágenes del usuario
@JsonSerializable()
class Photo {
  /// Constructor
  Photo({this.value, this.type, this.primary});

  /// URL de la imagen
  String value;

  /// Tipo de imagen
  String type;

  /// ¿Primaria?
  bool primary;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}

/// Clase Emails, para los correos electrónicos del usuario
@JsonSerializable()
class Email {
  /// Constructor
  Email({this.value, this.type, this.primary});

  /// Correo electrónico
  String value;

  /// Tipo de correo
  String type;

  /// ¿Primario?
  bool primary;

  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);

  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

/// Clase ScreenHelp
@JsonSerializable()
class HelpScreen {
  HelpScreen({this.name, this.active});
  String name;
  bool active;

  factory HelpScreen.fromJson(Map<String, dynamic> json) =>
      _$HelpScreenFromJson(json);
  Map<String, dynamic> toJson() => _$HelpScreenToJson(this);
}

/// Clase JsonUserList para extraer usuarios que vienen como lista en un json
@JsonSerializable(fieldRename: FieldRename.pascal)
class JsonUserList {
  /// Constructor
  JsonUserList({this.usersList});

  /// Lista de empresas capturada en json
  List usersList;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory JsonUserList.fromJson(Map<String, dynamic> json) =>
      _$JsonUserListFromJson(json);
}

// -----------------------------------------Company y asociadas-----------------------------------
/// Clase Company
@JsonSerializable(explicitToJson: true)
class Company {
  /// Constructor
  Company(
      {this.id,
      this.companyCode,
      this.name,
      this.addresses,
      this.externalId,
      this.locations,
      this.logo,
      this.roles});

  /// ID en base de datos
  @JsonKey(name: 'id')
  String id;

  /// Identificador de la empresa
  String companyCode;

  /// Nombre de la empresa
  String name;

  /// Lista de direcciones
  List<CompanyAddress> addresses;

  /// Identificador externo (NIT)
  String externalId;

  /// Lista de sedes
  List<String> locations;

  /// Logo
  String logo;

  /// Lista de roles
  List<CompanyRole> roles;

  /// Convertir de json a clase
  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  /// Copia de datos de la empresa
  Company copy() => Company(
      id: id,
      companyCode: companyCode,
      name: name,
      addresses: addresses,
      externalId: externalId,
      locations: locations,
      logo: logo,
      roles: roles);
}

/// Clase CompanyAddress, para las direcciones de la compañía
@JsonSerializable()
class CompanyAddress {
  /// Constructor
  CompanyAddress(
      {this.primary,
      this.streetAddress,
      this.locality,
      this.region,
      this.country});

  /// ¿Primaria?
  bool primary;

  /// Dirección
  String streetAddress;

  /// Municipio
  String locality;

  /// Provincia
  String region;

  /// País
  String country;

  factory CompanyAddress.fromJson(Map<String, dynamic> json) =>
      _$CompanyAddressFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyAddressToJson(this);
}

/// Clase CompanyRole, para los roles de la compañía
@JsonSerializable()
class CompanyRole {
  /// Constructor
  CompanyRole({this.name, this.roleId});

  /// Nombre del rol
  String name;

  /// ID del rol
  String roleId;

  factory CompanyRole.fromJson(Map<String, dynamic> json) =>
      _$CompanyRoleFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyRoleToJson(this);
}

/// Clase JsonCompanyList para extraer empresas que vienen como lista en un json
@JsonSerializable(fieldRename: FieldRename.pascal)
class JsonCompanyList {
  /// Constructor
  JsonCompanyList({this.companyList});

  /// Lista de empresas capturada en json
  List companyList;

  /// Convertir de json a clase
  // ignore: sort_constructors_first
  factory JsonCompanyList.fromJson(Map<String, dynamic> json) =>
      _$JsonCompanyListFromJson(json);
}

/// Clase Location para la sedes y ubicaciones
@JsonSerializable(fieldRename: FieldRename.pascal)
class Location {
  /// Constructor
  Location(
      {this.name,
      this.address,
      this.city,
      this.department,
      this.country,
      this.images});

  /// Nombre de la sede
  String name;

  /// Dirección
  String address;

  /// Ciudad
  String city;

  /// Departamento
  String department;

  /// País
  String country;

  /// Lista de imágenes
  List<String> images;

  /// Convertir de json a clase
  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

// ------------------------------------------------------------------
// Modelos adicionales para Provider
// ------------------------------------------------------------------

/// Estados de la empresa
enum CompanyStatus {
  /// En espera
  idle,

  /// Cargando
  loading,

  /// Cargado
  loaded,

  /// Error genérico
  error
}

/// Modelo de empresa
class CompanyModel with ChangeNotifier {
  /// Datos de la empresa del usuario actual
  Company currentCompany;

  /// Nombre de la empresa actual
  String name;

  /// Sede seleccionada
  String currentLocation;

  /// Listado de sedes
  List<String> places = [];

  /// Estado actual de carga de empresa
  CompanyStatus status = CompanyStatus.idle;

  /// Respuesta futura de lista de empresas a decodificar
  JsonCompanyList fetchedCompanies = JsonCompanyList();

  /// Lista de empresas completas
  List<Company> fullCompanyList = <Company>[];

  /// Lista temporal de roles de la empresa activa
  List<String> tempRoles = <String>[];

  /// Empresa actual en edición
  Company tempCompany;

  /// Ubicación actual en edición
  Location tempLocation;

  /// Lista de imágenes cargadas
  List<PlatformFile> imageArray = [];

  // Variables para campos de texto de búsqueda
  /// Búsqueda por nombre
  String currentSearchName;

  /// Búsqueda por código
  String currentSearchCode;

  // Reiniciar todas las variables de este modelo
  void resetAll() {
    currentCompany = null;
    name = null;
    currentLocation = null;
    places = [];
    status = CompanyStatus.idle;
    fetchedCompanies = JsonCompanyList();
    fullCompanyList = <Company>[];
    tempRoles = <String>[];
    tempCompany = null;
    tempLocation = null;
    imageArray = [];
  }

  /// Actualizar nombre de empresa seleccionada
  void updateName() {
    name = currentCompany.name;
    notifyListeners();
  }

  /// Cambio de sede seleccionada
  void changeLocation(String newLocation) {
    currentLocation = newLocation;
    notifyListeners();
  }

  /// Reiniciar sedes
  void resetLocation() {
    currentLocation = null;
    places.clear();
    notifyListeners();
  }

  /// Agregar elemento a lista de imágenes
  void addPicture(PlatformFile newItem) {
    imageArray.add(newItem);
    notifyListeners();
  }

  /// Remover elemento de lista de imágenes
  void removePicture(int index) {
    imageArray.removeAt(index);
    notifyListeners();
  }

  /// Finalizó edición de empresa
  void editDone() {
    notifyListeners();
  }

  /// Búsqueda de empresa por nombre
  void changeSearchName(String name) {
    currentSearchName = name;
    notifyListeners();
  }

  /// Búsqueda de empresa por código
  void changeSearchCode(String code) {
    currentSearchCode = code;
    notifyListeners();
  }

  /// Carga de datos de empresa
  Future<void> loadCompany(String companyName) async {
    status = CompanyStatus.loading;
    final futureResult = await getCompany(companyName);
    if (futureResult == 'Empresa cargada') {
      status = CompanyStatus.loaded;
    } else {
      status = CompanyStatus.error;
    }
    notifyListeners();
  }

  /// Función para obtener información de la empresa
  Future<String> getCompany(String companyId) async {
    // Armar la solicitud GET/POST con la URL de la página y el parámetro
    final response = await http.get(Config.companyDataURL + companyId);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic temp = json.decode(response.body);
        if (temp is Map<String, dynamic>) {
          currentCompany = Company.fromJson(temp);
          if (currentCompany.name != null) {
            return 'Empresa cargada';
          } else {
            return 'Error obteniendo datos de empresa';
          }
        } else {
          return 'Error obteniendo datos de empresa';
        }
      } on Exception {
        return 'Error obteniendo datos de empresa';
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Error del Servidor');
      return 'Error del Servidor';
    }
  }

  /// Carga de lista de empresas
  Future<void> loadCompanies() async {
    status = CompanyStatus.loading;
    notifyListeners();
    final futureResult = await getCompanyList();
    if (futureResult == 'Listado recibido') {
      extractCompanies();
      status = CompanyStatus.loaded;
    } else {
      status = CompanyStatus.error;
    }
    notifyListeners();
  }

  /// Función para obtener lista de empresas a través de HTTP
  Future<String> getCompanyList() async {
    // Parámetros de solicitud GET
    const paramString = '?Authorization=Henutsen';
    // Armar la solicitud GET/POST con la URL de la página y el parámetro
    final response = await http.get(Config.fullCompanyDataURL + paramString);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic temp = json.decode(response.body);
        if (temp is Map<String, dynamic>) {
          fetchedCompanies = JsonCompanyList.fromJson(temp);
          return 'Listado recibido';
        } else {
          return 'Error obteniendo empresas (tipo de datos).';
        }
      } on Exception {
        return 'Error obteniendo empresas.';
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Error del Servidor');
      return 'Error del Servidor';
    }
  }

  /// Método para extraer empresas
  void extractCompanies() {
    // Llenar lista total
    final dynamic companyList = fetchedCompanies.companyList;
    if (companyList is List) {
      final numComp = companyList.length;
      fullCompanyList.clear();
      for (var i = 0; i < numComp; i++) {
        final dynamic temp = fetchedCompanies.companyList[i];
        if (temp is Map<String, dynamic>) {
          final comp = Company.fromJson(temp);
          fullCompanyList.add(comp);
        }
      }
    }
  }

  /// Método para extraer sedes de la empresa seleccionada
  void getLocations() {
    final dynamic numLocations = currentCompany.locations.length;
    if (numLocations is int) {
      for (var i = 0; i < numLocations; i++) {
        if (!places.contains(currentCompany.locations[i])) {
          places.add(currentCompany.locations[i].toString());
        }
      }
    }
  }
}

/// Estados del activo en la base de datos
enum AssetCondition {
  /// De baja (ya no cuenta)
  deBaja,

  /// De alta (operativo)
  deAlta,

  /// En reparación
  enReparacion,

  /// En tránsito (aún no llega)
  enTransito,

  /// Sobrante en préstamo (en esta ubicación, viene de otra parte)
  sobranteEnPrestamo,

  /// Faltante en préstamo (en otra ubicación)
  faltanteEnPrestamo
}

/// Estados del inventario
enum StocktakingStatus {
  /// En espera
  idle,

  /// Cargando
  loading,

  /// Cargado
  loaded,

  /// Contando
  counting,

  /// Pausado
  paused,

  /// Finalizado
  finished,

  /// Cancelado
  canceled,

  /// Error
  error
}

/// Modelo para inventarios
class InventoryModel with ChangeNotifier {
  /// Lista de inventarios completos de una empresa
  List<Asset> fullInventory = <Asset>[];

  /// Lista de inventarios en la ubicación actual
  List<Asset> localInventory = <Asset>[];

  /// Lista de tags encontrados
  List<AssetRead> tagList = [];

  /// Resultado del conteo
  Stocktaking assetsResult = Stocktaking();

  /// Respuesta futura de inventarios de la empresa
  JsonAssetList fetchedInventory = JsonAssetList();

  /// Estado actual de carga de inventarios
  StocktakingStatus status = StocktakingStatus.idle;

  /// Listado de categorías a mostrar
  List<String> categories = [];

  /// Categoría seleccionada
  String currentCategory;

  /// Código obtenido de: 0-rfid, 1-barras
  int codeSource = 0;

  /// Activo actual en visualización/edición
  Asset currentAsset;

  /// Valores posibles para el estado de un activo
  final conditions = <String>[
    'Operativo',
    'De baja',
    'En reparación',
    'Defectuoso',
    'Sustituido por garantía',
    'En préstamo',
    'Disposición final',
    'Faltante',
    'Pre de baja',
    'En tránsito',
    'Perdido',
    'Sobrante en préstamo',
    'Faltante en préstamo'
  ];
  // Lista de imágenes cargadas
  List<PlatformFile> imageArray = [];
  // Última ubicación donde se hizo conteo
  String lastStockTakingLocation;
  // Variables para campos de texto de búsqueda
  /// Búsqueda por nombre
  String currentSearchName;

  /// Búsqueda por código
  String currentSearchCode;

  // Reiniciar todas las variables de este modelo
  void resetAll() {
    fullInventory = <Asset>[];
    localInventory = <Asset>[];
    tagList = [];
    assetsResult = Stocktaking();
    fetchedInventory = JsonAssetList();
    status = StocktakingStatus.idle;
    categories = [];
    currentCategory = null;
    codeSource = 0;
    currentAsset = null;
    imageArray = [];
    lastStockTakingLocation = null;
    currentSearchName = null;
    currentSearchCode = null;
  }

  /// Inicializar listas de inventarios
  void initInventory() {
    assetsResult.assets = <AssetStatus>[];
    fullInventory = [];
    localInventory = [];
    fetchedInventory.assetsList = <Asset>[];
  }

  /// Agregar elemento a lista de tags leídos
  void addTag(AssetRead newItem) {
    tagList.add(newItem);
    notifyListeners();
  }

  /// Limpiar lista de tags leídos
  void clearTagList() {
    tagList.clear();
    notifyListeners();
  }

  /// Cambio de categoría seleccionada
  void changeCategory(String newCategory) {
    currentCategory = newCategory;
    notifyListeners();
  }

  /// Agregar elemento a lista de imágenes
  void addPicture(PlatformFile newItem) {
    imageArray.add(newItem);
    notifyListeners();
  }

  /// Remover elemento de lista de imágenes
  void removePicture(int index) {
    imageArray.removeAt(index);
    notifyListeners();
  }

  /// Búsqueda de activo por nombre
  void changeSearchName(String name) {
    currentSearchName = name;
    notifyListeners();
  }

  /// Búsqueda de activo por código
  void changeSearchCode(String code) {
    currentSearchCode = code;
    notifyListeners();
  }

  /// Cambio del estado de un activo en creación
  void changeAssetCondition(String status) {
    currentAsset.status = status;
    notifyListeners();
  }

  /// Finalizó edición de elemento del inventario
  void editDone() {
    notifyListeners();
  }

  /// Cambio de ubicación del activo en creación
  void changeLocation(String newLocation) {
    currentAsset.locationName = newLocation;
    notifyListeners();
  }

  /// Método para extraer categorías de inventario
  void getCategories() {
    categories.clear();
    // Opción para "Todas las categorías"
    categories.add('Todas');
    // Llenar listado de categorías diferentes y no vacías
    for (var i = 0; i < fullInventory.length; i++) {
      final itemCategory = getAssetMainCategory(fullInventory[i].assetCode);
      if (!categories.contains(itemCategory)) {
        if (itemCategory.isNotEmpty) {
          categories.add(itemCategory);
        }
      }
    }
  }

  /// Obtener categoría principal de un activo específico
  String getAssetMainCategory(String code) {
    var cat = '';
    for (final item in fullInventory) {
      if (item.assetCode == code) {
        if (item.categories != null) {
          if (item.categories.isNotEmpty) {
            cat = item.categories[0].value;
          }
        }
        break;
      }
    }
    return cat;
  }

  /// Carga de inventario
  Future<void> loadInventory(Company company) async {
    status = StocktakingStatus.loading;
    notifyListeners();
    final _futureInventoryResult = await getInventory(company);
    if (_futureInventoryResult == 'Inventario recibido') {
      status = StocktakingStatus.loaded;
      extractAllItems();
    } else {
      status = StocktakingStatus.error;
    }
    notifyListeners();
  }

  /// Función para obtener inventario a través de HTTP
  Future<String> getInventory(Company company) async {
    // Parámetros de solicitud GET
    final paramString = '?CompanyCode=${company.companyCode}';
    // Armar la solicitud GET/POST con la URL de la página y el parámetro
    final response = await http.get(Config.inventoryDataURL + paramString);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic temp = json.decode(response.body);
        if (temp is Map<String, dynamic>) {
          fetchedInventory = JsonAssetList.fromJson(temp);
          return 'Inventario recibido';
        } else {
          return 'Error obteniendo inventarios (tipo de datos).';
        }
      } on Exception {
        return 'Error obteniendo inventarios.';
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error del Servidor');
    }
  }

  /// Método para asignar inventarios a la empresa seleccionada
  void extractAllItems() {
    // Llenar lista de inventario total
    final dynamic assetsList = fetchedInventory.assetsList;
    if (assetsList is List) {
      final numAssets = assetsList.length;
      fullInventory.clear();
      for (var i = 0; i < numAssets; i++) {
        final dynamic temp = fetchedInventory.assetsList[i];
        if (temp is Map<String, dynamic>) {
          final asset = Asset.fromJson(temp);
          fullInventory.add(asset);
        }
      }
    }
  }

  /// Método para asignar inventarios a la sede seleccionada
  void extractLocalItems(String currentLocation) {
    // Crear lista de inventario para la ubicación actual
    localInventory.clear();
    for (final item in fullInventory) {
      if (item.locationName == currentLocation) {
        localInventory.add(item);
      }
    }
  }

  /*
  /// Método para iniciar escaneo de tags
  Future <void> startInventory(BluetoothModel device) async {

  /// Método para iniciar escaneo de tags
  Future<void> startInventory(BluetoothModel device) async {
    if (device.isRunning) {
      return;
    }
    device.isRunning = true;
    final thisResponse = await r6_plugin.getAllTagsStart();
    try {
      if (thisResponse != null) {
        if (thisResponse) {
          device
            ..loopFlag = true
            ..isScanning = true;
        }
        device.isRunning = false;
        while (device.loopFlag) {
          List<String> tagListHere;
          switch (device.memBank) {
            case 0:
              tagListHere = await r6_plugin.getTagEPCList();
              break;
            case 1:
              tagListHere = await r6_plugin.getTagTIDList();
              break;
            case 2:
              tagListHere = await r6_plugin.getTagUserList();
              break;
          }
          if (tagListHere == null || tagListHere.isEmpty) {
            sleep(const Duration(milliseconds: 1));
          } else {
            addTagToList(tagListHere);
          }
        }
      }
    } on Exception {
      //  _showToast('Error de lectura', context);
    }
  }

  /// Método para detener escaneo de tags
  Future<void> stopInventory(BluetoothModel device) async {
    device.loopFlag = false;
    final thisResponse = await r6_plugin.getAllTagsStop();
    if (thisResponse != null) {
      if (thisResponse) {
        if (device.isScanning) {
          device.isScanning = false;
        }
      }
    }
  }
  */
  /// Método para iniciar escaneo de tags
  Future<void> startInventory(BluetoothModel device) async {
    if (device.isRunning) {
      return;
    }
    device
      ..isRunning = true
      ..loopFlag = true
      ..isScanning = true
      ..isRunning = false;
    while (device.loopFlag) {
      String tagListHere;
      switch (device.memBank) {
        case 0:
          tagListHere = await r6_plugin.getTagEPC();
          break;
        case 1:
          tagListHere = await r6_plugin.getTagTID();
          break;
        case 2:
          tagListHere = await r6_plugin.getTagUser();
          break;
      }
      if (tagListHere == null || tagListHere.startsWith('No hay')) {
        sleep(const Duration(milliseconds: 1));
      } else {
        addTagToList([tagListHere]);
      }
    }
  }

  /// Método para detener escaneo de tags
  Future<void> stopInventory(BluetoothModel device) async {
    device.loopFlag = false;
    if (device.isScanning) {
      device.isScanning = false;
    }
  }

  /// Método para agregar los EPC leídos a nuestra lista
  void addTagToList(List<String> myList) {
    // Para usar la clase AssetCode
    final assetCodeTemp = AssetCode();

    // Repasar lista de tags leídos
    for (var k = 0; k < myList.length; k++) {
      if (!(myList[k] == null) && !(myList[k] == '')) {
//        print('Agregando tags a lista');
//        print(myList[k]);
//        print('Longitud válida: ${assetCodeTemp.checkEPCLength(myList[k])}');
//        print('Formato GIAI96: ${assetCodeTemp.checkEPCGIAI96(myList[k])}');
//        print(
//           'Cabecera Henutsen: ${assetCodeTemp.checkEPCHenutsen(myList[k])}');
        //assetCodeTemp.uri = assetCodeTemp.epcAsEPCTagUri(myList[k]);
        //print(assetCodeTemp.uri);

        // Revisar si es un tag válido
        bool _validData;
        // Opción tag RFID
        if (codeSource == 0 &&
            assetCodeTemp.checkEPCLength(myList[k]) &&
            assetCodeTemp.checkEPCGIAI96(myList[k]) &&
            assetCodeTemp.checkEPCHenutsen(myList[k])) {
          //Convertir a EPC Tag Uri
          assetCodeTemp.uri = assetCodeTemp.epcAsEPCTagUri(myList[k]);
          //print(assetCodeTemp.uri);
          _validData = true;
          // Opción código de barras
        } else if (codeSource == 1 &&
            assetCodeTemp.checkBarcodeGIAI96(myList[k]) &&
            assetCodeTemp.checkBarcodeHenutsen(myList[k])) {
          //Convertir a EPC Tag Uri
          assetCodeTemp.uri = assetCodeTemp.barcodeAsEPCTagUri(myList[k]);
          //print(assetCodeTemp.uri);
          _validData = true;
        } else {
          _validData = false;
        }

        if (_validData) {
          // Revisar si aún no está incluido en la lista
          var alreadyRead = false;
          for (final item in tagList) {
            if (item.assetCode == assetCodeTemp.uri) {
              alreadyRead = true;
              break;
            }
          }
          if (!alreadyRead) {
            // Recorrer el inventario total y verificar si el tag está
            for (final subitem in fullInventory) {
              if (subitem.assetCode == assetCodeTemp.uri) {
                addTag(AssetRead(
                    assetCode: subitem.assetCode,
                    location: subitem.locationName,
                    name: subitem.name,
                    found: false));
              }
            }
          }
        }
      }
    }
  }

  /// Método para procesar lecturas de códigos de barras
  Future<void> readBarcode(BluetoothModel device) async {
    codeSource = 1;
    if (device.isRunning) {
      return;
    }
    device.isRunning = true;
    final thisResponse = await r6_plugin.scanBarcode();
    if (thisResponse != null && thisResponse.isNotEmpty) {
      print(thisResponse);
      addTagToList([thisResponse]);
    }
    device.isRunning = false;
    codeSource = 0;
  }

  /// Función para hacer petición POST y enviar reporte
  Future<String> sendReport(String thingToSend, String companyCode) async {
    // Armar la solicitud con la URL de la página y el parámetro
    final response = await http.post(Config.stocktakingURL,
        body: thingToSend,
        headers: {
          'Content-Type': 'application/json',
          'CompanyCode': companyCode
        });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response:
      if (response.body != 'Acceso inválido') {
        return 'Ok';
      } else {
        return 'Error enviando reporte';
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error del Servidor');
    }
  }

  /// Función para hacer petición PATCH y modificar el activo
  Future<String> modifyAsset(List<PlatformFile> files2send, String thingToSend,
      String userName) async {
    // Armar la solicitud con la URL de la página y el parámetro
    /*
    final response = await http.patch(modifyAssetURL,
      body: thingToSend,
      headers: {'Content-Type': 'application/json', 'UserName': userName});
    */

    // Armar petición multiparte
    final url = Uri.parse(Config.modifyAssetURL);
    var request = http.MultipartRequest('PATCH', url);
    // Armar la solicitud con los campos adecuados
    for (var i = 0; i < files2send.length; i++) {
      request.files
          .add(http.MultipartFile.fromBytes('file$i', files2send[i].bytes,
              //contentType: MediaType('text', 'csv'),
              filename: files2send[i].name));
    }
    // Campos adicionales
    request.fields['body'] = thingToSend;
    request.headers
        .addAll({'Content-Type': 'application/json', 'UserName': userName});

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      // If the server did return a 200 OK response:
      try {
        final response = await http.Response.fromStream(streamedResponse);
        if (response.body == 'Activo modificado') {
          return 'Ok';
        } else {
          return response.body;
        }
      } on Exception {
        return 'Error fatal';
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Error del Servidor');
      return 'Error del Servidor';
    }
  }
}

/// Modelo para dispositivo Bluetooth
// ignore: prefer_mixin
class BluetoothModel with ChangeNotifier {
  /// Dispositivo bluetooth
  BluetoothDevice connectedDevice;

  /// Bandera para indicar si actualmente se está escaneando tags
  bool isScanning = false;

  /// Banco de memoria a leer - 0:EPC, 1:TID, 2:User
  int memBank = 0;

  /// Bandera para indicar si ya tenemos un dispositivo conectado
  bool gotDevice = false;

  /// Bandera que indica si se está leyendo para evitar interrupciones
  bool isRunning = false;

  /// Bandera que indica si se está en un loop de lectura
  bool loopFlag = false;

  /// Bandera para indicar si ya se asignó callback de gatillo
  bool callbackSet = false;

  // Reiniciar todas las variables de este modelo
  void resetAll() {
    connectedDevice = null;
    isScanning = false;
    memBank = 0;
    gotDevice = false;
    isRunning = false;
    loopFlag = false;
    callbackSet = false;
  }

  /// Actualizar estado de conexión a true
  void setConnectionStatus() {
    gotDevice = true;
    notifyListeners();
  }

  /// Actualizar estado de conexión a false
  void unsetConnectionStatus() {
    gotDevice = false;
    notifyListeners();
  }
}

/// Estados del usuario
enum UserStatus {
  /// En espera
  idle,

  /// Cargando
  loading,

  /// Cargado
  loaded,

  /// Error de contraseña
  passwordError,

  /// Usuario no autorizado
  userNotAuthorized,

  /// Usuario no activo
  userNotActive,

  /// Error genérico
  error
}

/// Modelo para el usuario
class UserModel with ChangeNotifier {
  /// Nombre del usuario
  String name;

  /// Correo del usuario
  String userName;

  /// Contraseña del usuario
  String password;

  /// Información del usuario actual en sesión
  User currentUser;

  /// Rol del usuario actual
  String currentUserRole;

  /// Estado actual de carga de usuario
  UserStatus status = UserStatus.idle;

  /// Datos del usuario en creación/modificación
  User tempUser;

  /// Rol actual seleccionado del usuario en creación/modificación
  String tempRole;

  /// Tipo de documento del usuario en creación/modificación
  String docType;

  /// Número de documento del usuario en creación/modificación
  String docNum;

  // Bandera que me dice si el check esta presionado o no para la pantalla de ayuda
  bool helpScreen = false;
  // Lista de imágenes cargadas
  List<PlatformFile> imageArray = [];

  // Bandera para pantalla de ayuda Carga Masivas
  bool uploading = false;

  // Bandera para pantalla de ayuda Conteo
  bool stockTaking = false;

  // Bandera para pantalla de ayuda indicadorGestion
  bool indicatorG = false;

  // Bandera para pantalla de ayuda indicadorGestion
  bool printing = false;

  // Bandera para pantalla de ayuda gestion
  bool management = false;

  // Bandera para pantalla de ayuda codificar
  bool encode = false;

  // Bandera para pantalla de ayuda codificar
  bool configuration = false;

  /// Respuesta futura de lista de usuarios a decodificar
  JsonUserList fetchedUsers = JsonUserList();

  /// Lista completa de usuarios
  List<User> fullUserList = <User>[];

  // Variables para campos de texto de búsqueda
  /// Búsqueda por nombre
  String currentSearchName;

  /// Búsqueda por código
  String currentSearchCode;

  // Reiniciar todas las variables de este modelo
  void resetAll() {
    name = null;
    currentUser = null;
    currentUserRole = null;
    status = UserStatus.idle;
    tempUser = null;
    tempRole = null;
    docType = null;
    docNum = null;
    helpScreen = false;
    imageArray = [];
    notifyListeners();
  }

  /// Cambiar bandera de estado config
  void changeConfiguration(bool value) {
    this.configuration = value;
    notifyListeners();
  }

  /// Cambiar bandera de estado codificar
  void changeEncode(bool value) {
    this.encode = value;
    notifyListeners();
  }

  /// Cambiar bandera de estado gestion
  void changeManagement(bool value) {
    this.management = value;
    notifyListeners();
  }

  /// Cambiar bandera de estado imprimir
  void changePrinting(bool value) {
    this.printing = value;
    notifyListeners();
  }

  /// Cambiar bandera de estado Conteo
  void changeindicatorG(bool value) {
    this.indicatorG = value;
    notifyListeners();
  }

  /// Cambiar bandera de estado Conteo
  void changeStockTaking(bool value) {
    this.stockTaking = value;
    notifyListeners();
  }

  /// Cambiar bandera de estado Carga Masiva
  void changeUploading(bool value) {
    this.uploading = value;
    notifyListeners();
  }

  /// cambio de bandera
  void changeHelp(bool value) {
    helpScreen = value;
    notifyListeners();
  }

  /// Cambio de nombre del usuario
  void changeName(String newName) {
    name = newName;
    notifyListeners();
  }

  /// Cambio de rol del usuario en creación
  void changeRole(String newRole) {
    tempRole = newRole;
    notifyListeners();
  }

  /// Cambio de empresa del usuario en creación
  void changeCompany(String newCompany) {
    tempUser.organization = newCompany;
    notifyListeners();
  }

  /// Cambio de documento del usuario en creación
  void changeDocType(String newType) {
    docType = newType;
    notifyListeners();
  }

  /// Agregar elemento a lista de imágenes
  void addPicture(PlatformFile newItem) {
    imageArray.add(newItem);
    notifyListeners();
  }

  /// Remover elemento de lista de imágenes
  void removePicture(int index) {
    imageArray.removeAt(index);
    notifyListeners();
  }

  /// Búsqueda de usuario por nombre
  void changeSearchName(String name) {
    currentSearchName = name;
    notifyListeners();
  }

  /// Búsqueda de usuario por código
  void changeSearchCode(String code) {
    currentSearchCode = code;
    notifyListeners();
  }

  /// Finalizó edición de elemento del inventario
  void editDone() {
    notifyListeners();
  }

  /// Cadena json para solicitar acceso
  String loginInfo() => '{"UserName":"$userName","Password":"$password"}';

  /// Carga de usuario
  Future<void> loadUser(String userInfo) async {
    status = UserStatus.loading;
    notifyListeners();
    final futureUserResult = await fetchUser(userInfo);
    if (futureUserResult == 'Usuario cargado') {
      status = UserStatus.loaded;
    } else if (futureUserResult == 'Contraseña incorrecta') {
      status = UserStatus.passwordError;
    } else if (futureUserResult == 'Usuario no encontrado') {
      status = UserStatus.userNotAuthorized;
    } else if (futureUserResult == 'Usuario inactivo') {
      status = UserStatus.userNotActive;
    } else {
      status = UserStatus.error;
    }
    notifyListeners();
  }

  /// Función para hacer petición POST y obtener datos del usuario
  Future<String> fetchUser(String userInfo) async {
    // Armar la solicitud GET/POST con la URL de la página y el parámetro
    //final response = await http.post(userDataURL, body: loginInfo());
    final response = await http.post(Config.userLoginURL, body: userInfo);

    //print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic temp = json.decode(response.body);
        if (temp is Map<String, dynamic>) {
          currentUser = User.fromJson(temp);
          for (var itemUser in currentUser.helpScreens) {
            if (itemUser.name == 'gestion') {
              this.management = itemUser.active;
            } else if (itemUser.name == 'conteo') {
              this.stockTaking = itemUser.active;
            } else if (itemUser.name == 'imprimir') {
              this.printing = itemUser.active;
            } else if (itemUser.name == 'indicadorGestion') {
              this.indicatorG = itemUser.active;
            } else if (itemUser.name == 'config') {
              this.configuration = itemUser.active;
            } else if (itemUser.name == 'codificar') {
              this.encode = itemUser.active;
            } else {
              this.uploading = itemUser.active;
            }
          }
          name = '${currentUser.name.givenName} ${currentUser.name.familyName}';
          if (currentUser.roles == null) {
            currentUserRole = '';
          } else if (currentUser.roles.isEmpty) {
            currentUserRole = '';
          } else {
            currentUserRole = currentUser.roles.first;
          }
          return 'Usuario cargado';
        } else {
          return 'Error obteniendo datos de usuario';
        }
      } on Exception {
        return 'Error obteniendo datos de usuario';
      }
    } else {
      //print(response.body);
      if (response.body == 'Usuario incorrecto') {
        return 'Usuario no encontrado';
      } else if (response.body == 'Usuario incorrecto') {
        return 'Usuario no encontrado';
      } else if (response.body == 'Error en las credenciales del usuario') {
        return 'Contraseña incorrecta';
      } else if (response.body == 'El usuario se encuentra inhabilitado') {
        return 'Usuario inactivo';
      } else {
        return 'Error del servidor';
      }
    }
  }

  /// Función para obtener lista de usuarios a través de HTTP
  Future<String> getUserList() async {
    // Parámetros de solicitud GET
    const paramString = '?Authorization=Henutsen';
    // Armar la solicitud GET/POST con la URL de la página y el parámetro
    final response = await http.get(Config.fullUserDataURL + paramString);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic temp = json.decode(response.body);
        if (temp is Map<String, dynamic>) {
          fetchedUsers = JsonUserList.fromJson(temp);
          return 'Listado recibido';
        } else {
          return 'Error obteniendo usuarios (tipo de datos).';
        }
      } on Exception {
        return 'Error obteniendo usuarios.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para extraer usuarios
  void extractUsers() {
    // Llenar lista total
    final dynamic userList = fetchedUsers.usersList;
    if (userList is List) {
      final numUsers = userList.length;
      fullUserList.clear();
      for (var i = 0; i < numUsers; i++) {
        final dynamic temp = fetchedUsers.usersList[i];
        if (temp is Map<String, dynamic>) {
          final myUser = User.fromJson(temp);
          fullUserList.add(myUser);
        }
      }
    }
  }
}

/// Modos de impresión
enum PrintMode {
  /// Tag RFID
  rfid,

  /// Código de barras
  barcode,

  /// Tag RFID + Código de barras
  rfidAndBarcode
}

/// Modelo para la impresora
// ignore: prefer_mixin
class PrinterModel with ChangeNotifier {
  /// Listas de selección
  List<String> printers = [];

  /// Impresora seleccionada
  String currentPrinter;

  /// Dirección del servidor de impresión
  String serverUrl = '';

  /// Ancho de tag
  int tagWidth;

  /// Altura de tag
  int tagHeight;

  /// Espacio entre tags
  int tagGap;

  /// Plugin para conectar con impresora
  PostekPlugin postek = PostekPlugin(http.Client());

  /// Lista de etiquetas de activos a imprimir
  List<List<String>> tags2print = [];

  /// Modo de impresión seleccionado
  PrintMode printMode = PrintMode.rfid;

  /// Etiqueta imprimiento actualmente
  int currentPrintingTag = 0;

  /// Status de impresión
  bool paused = false;

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    printers = [];
    currentPrinter = null;
    serverUrl = '';
    tagWidth = null;
    tagHeight = null;
    tagGap = null;
    postek = PostekPlugin(http.Client());
    tags2print = [];
    printMode = PrintMode.rfid;
    currentPrintingTag = 0;
    paused = false;
  }

  /// Cambio de impresora seleccionada
  void changePrinter(String newPrinter) {
    currentPrinter = newPrinter;
    notifyListeners();
  }

  /// Agregar impresora a la lista
  void addPrinter(String newPrinter) {
    printers.add(newPrinter);
    notifyListeners();
  }

  /// Agregar tag a la lista de impresión
  void addAsset(Asset asset) {
    // Para usar la clase AssetCode
    final assetCodeTemp = AssetCode()..uri = asset.assetCode;
    // Lista de cuatro posiciones, con URi en formato EPC y código de barras
    // (también incluye URI original y nombre del activo)
    final assetOutput = <String>[
      assetCodeTemp.asEpcHex,
      assetCodeTemp.asBarcode,
      assetCodeTemp.uri,
      asset.name
    ];
    tags2print.add(assetOutput);
  }

  /// Agregar tag a la lista de impresión
  void updatePrintMode(PrintMode mode) {
    printMode = mode;
    notifyListeners();
  }

  /// Actualizar tag siendo impreso
  void updatePrintedTag() {
    currentPrintingTag++;
    notifyListeners();
  }

  /// Pausar impresión
  void pausePrint() {
    paused = true;
    notifyListeners();
  }

  /// Continuar impresión
  void resumePrint() {
    paused = false;
    notifyListeners();
  }

  /// Actualizar dirección del servidor de impresión
  void updateURL(String address) {
    serverUrl = address;
    notifyListeners();
  }

  /// Método para imprimir tag RFID
  Future<bool> printRFIDTag(String tag) async {
    final result = await postek.writeRFID(serverUrl, currentPrinter,
        tagWidth.toString(), tagHeight.toString(), tagGap.toString(), tag);
    if (!result) {
      return false;
    } else {
      //print(tag);
      return true;
    }
  }

  /// Método para imprimir código de barras
  Future<bool> printBarcode(String tag) async {
    final result = await postek.printBarcode(serverUrl, currentPrinter,
        tagWidth.toString(), tagHeight.toString(), tagGap.toString(), tag);
    if (!result) {
      return false;
    } else {
      //print(tag);
      return true;
    }
  }

  /// Método para imprimir tag RFID y código de barras
  Future<bool> printRFIDBarcode(String printedTag, String rfidTag) async {
    final result = await postek.writeRFIDBarcode(
        serverUrl,
        currentPrinter,
        tagWidth.toString(),
        tagHeight.toString(),
        tagGap.toString(),
        printedTag,
        rfidTag);
    if (!result) {
      return false;
    } else {
      //print('$rfidTag $printedTag');
      return true;
    }
  }

  //_client.close();
}

/// Modelo para la estación de codificación
// ignore: prefer_mixin
class EncoderModel with ChangeNotifier {
  /// Estación seleccionada
  String currentEncoder;

  /// Etiqueta de activos a grabar
  List<String> tag2write = [];

  /// Información del lector
  Map<String, String> info = {
    'FirmwareVersion': '',
    'Power': '',
    'Address': '',
    'ScanTime': '',
    'FrequencyBand': '',
    'MinFrequency': '',
    'MaxFrequency': '',
    'Reader': '',
    'Protocols': ''
  };

  /// Tag ha sido detectado
  bool tagDetected = false;

  /// Tag ha sido escrito
  bool tagWritten = false;

  /// Tag detectado
  String foundTag = '';

  /// Dirección del servidor de codificación
  String serverUrl = '';

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    currentEncoder = null;
    tag2write = [];
    tagDetected = false;
    tagWritten = false;
    foundTag = '';
  }

  /// Asignar codificador
  void asignEncoder(String encoder) {
    currentEncoder = encoder;
    notifyListeners();
  }

  /// Cambio de detección de tag
  void changeDetection(bool detectionValue) {
    tagDetected = detectionValue;
    notifyListeners();
  }

  /// Cambio de escritura de tag
  void changeWriting(bool writingValue) {
    tagWritten = writingValue;
    notifyListeners();
  }

  /// Actualizar dirección del servidor de impresión
  void updateURL(String address) {
    serverUrl = address;
    notifyListeners();
  }

  /// Agregar tag a la lista de impresión
  void addAsset(Asset asset) {
    // Para usar la clase AssetCode
    final assetCodeTemp = AssetCode()..uri = asset.assetCode;
    // Lista de tres posiciones, con URi en formato EPC
    // (también incluye URI original y nombre del activo)
    final assetOutput = <String>[
      assetCodeTemp.asEpcHex,
      assetCodeTemp.uri,
      asset.name
    ];
    tag2write = assetOutput;
  }

  /// Método para conectar a servidor de codificación
  Future<String> connectToServer() async {
    final endPoint = '/api/oppiot/connect';
    final response = await http.get(serverUrl + endPoint);

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        //print(response.body);
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is bool) {
          if (fetchedData) {
            return 'Ok';
          } else {
            return 'Error de conexión al lector.';
          }
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para desconectar servidor de codificación
  Future<String> disconnectFromServer() async {
    final endPoint = '/api/oppiot/disconnect';
    final response = await http.get(serverUrl + endPoint);

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is bool) {
          if (fetchedData) {
            return 'Ok';
          } else {
            return 'Error de conexión al lector.';
          }
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para obtener información del codificador
  Future<String> getEncoderInfo() async {
    final endPoint = '/api/oppiot/info';
    final response = await http.get(serverUrl + endPoint);

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        //print(response.body);
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is Map) {
          info['FirmwareVersion'] = fetchedData['FirmwareVersion'];
          info['Power'] = fetchedData['Power'];
          info['Address'] = fetchedData['Address'];
          info['ScanTime'] = fetchedData['ScanTime'];
          info['FrequencyBand'] = fetchedData['FrequencyBand'];
          info['MinFrequency'] = fetchedData['MinFrequency'];
          info['MaxFrequency'] = fetchedData['MaxFrequency'];
          info['Reader'] = fetchedData['Reader'];
          info['Protocols'] = fetchedData['Protocols'];
          return 'Ok';
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para leer tag
  Future<String> readTag() async {
    final endPoint = '/api/oppiot/inventory';
    final response = await http.get(serverUrl + endPoint);

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        //print(response.body);
        final dynamic fetchedData = response.body;
        return fetchedData.toString();
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }

  /// Método para grabar tag
  Future<String> writeTag(String data2write) async {
    final endPoint = '/api/oppiot/tagWrite';
    final param = '?dataToWrite=$data2write';
    final response = await http.get(serverUrl + endPoint + param);

    // Se espera una respuesta 200
    if (response.statusCode == 200) {
      try {
        final dynamic fetchedData = json.decode(response.body);
        if (fetchedData is bool) {
          if (fetchedData) {
            return 'Ok';
          } else {
            return 'Error de conexión al lector.';
          }
        } else {
          return 'Error de conexión al lector.';
        }
      } on Exception {
        return 'Error de conexión al lector.';
      }
    } else {
      return 'Error del Servidor';
    }
  }
}
