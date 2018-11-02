part of '../summary.dart';

/// JSON-serializable subset of code analysis information about a Dart library
/// containing dependency injection constructs.
///
/// A library summary generally corresponds to a ".dart" file.
class LibrarySummary {
  /// Creates a [LibrarySummary] by parsing the .inject.summary [json].
  static LibrarySummary parseJson(Map<String, Object> json) {
    if (json == null) {
      throw new ArgumentError.notNull('json');
    }

    var assetUri = Uri.parse(json['asset'] as String);
    Map<String, dynamic> summary =
        (json['summary'] as Map).cast<String, dynamic>();
    List<InjectorSummary> injectors = (summary['injector'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => _injectorFromJson(assetUri, e))
        .toList();
    List<ModuleSummary> modules = (summary['module'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => _moduleFromJson(assetUri, e))
        .toList();
    List<InjectableSummary> injectables = (summary['injectable'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => _injectableFromJson(assetUri, e))
        .toList();
    return new LibrarySummary(assetUri,
        injectors: injectors, modules: modules, injectables: injectables);
  }

  /// Points to the Dart file that defines the library from which this summary
  /// was extracted.
  ///
  /// The URI uses the "asset:" scheme.
  final Uri assetUri;

  /// Injector classes defined in the library.
  final List<InjectorSummary> injectors;

  /// Module classes defined in this library.
  final List<ModuleSummary> modules;

  /// Injectable classes.
  final List<InjectableSummary> injectables;

  /// Constructor.
  ///
  /// [assetUri], [injectors] and [modules] must not be `null`.
  factory LibrarySummary(Uri assetUri,
      {List<InjectorSummary> injectors: const [],
      List<ModuleSummary> modules: const [],
      List<InjectableSummary> injectables: const []}) {
    if (assetUri == null) {
      throw new ArgumentError.notNull('assetUri');
    }
    if (injectors == null) {
      throw new ArgumentError.notNull('injectors');
    }
    if (modules == null) {
      throw new ArgumentError.notNull('modules');
    }
    if (injectables == null) {
      throw new ArgumentError.notNull('injectables');
    }
    return new LibrarySummary._(assetUri, injectors, modules, injectables);
  }

  LibrarySummary._(
      this.assetUri, this.injectors, this.modules, this.injectables);

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {
      "asset": assetUri.toString(),
      "summary": {
        "injector": injectors,
        "module": modules,
        "injectable": injectables,
      }
    };
  }
}

InjectorSummary _injectorFromJson(Uri assetUri, Map<String, dynamic> json) {
  String name = json['name'] as String;
  List<SymbolPath> modules = (json['modules'] as List)
      .cast<String>()
      .map(Uri.parse)
      .map((e) => new SymbolPath.fromAbsoluteUri(e))
      .toList();
  List<ProviderSummary> providers = (json['providers'] as List)
      .cast<Map<String, dynamic>>()
      .map(_providerFromJson)
      .toList();
  var clazz = new SymbolPath.fromAbsoluteUri(assetUri, name);
  return new InjectorSummary(clazz, modules, providers);
}

ModuleSummary _moduleFromJson(Uri assetUri, Map<String, dynamic> json) {
  String name = json['name'] as String;
  List<Map<String, dynamic>> jsonList =
      (json['providers'] as List).cast<Map<String, dynamic>>();
  List<ProviderSummary> providers = jsonList.map(_providerFromJson).toList();
  var clazz = new SymbolPath.fromAbsoluteUri(assetUri, name);
  return new ModuleSummary(clazz, providers);
}

ProviderSummary _providerFromJson(Map<String, dynamic> json) {
  String name = json['name'] as String;
  var injectedTypeMap = (json['injectedType'] as Map).cast<String, dynamic>();
  var injectedType = new InjectedType.fromJson(injectedTypeMap);
  var singleton = json['singleton'] as bool;
  var asynchronous = json['asynchronous'] as bool;
  var kind = json['kind'] as String;
  final List<InjectedType> dependencies = (json['dependencies'] as List)
      .cast<Map<String, dynamic>>()
      .map((dependency) => new InjectedType.fromJson(dependency))
      .toList();
  return new ProviderSummary(
    injectedType,
    name,
    providerKindFromName(kind),
    singleton: singleton,
    asynchronous: asynchronous,
    dependencies: dependencies,
  );
}

InjectableSummary _injectableFromJson(Uri assetUri, Map<String, dynamic> json) {
  String name = json['name'] as String;
  var type = new SymbolPath.fromAbsoluteUri(assetUri, name);
  return new InjectableSummary(
    type,
    _providerFromJson(json['constructor'] as Map<String, dynamic>),
  );
}
