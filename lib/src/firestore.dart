import 'dart:async';

import 'package:js/js.dart';

import 'app.dart';
import 'interop/firestore_interop.dart' as firestore_interop;
import 'js.dart';
import 'utils.dart';

export 'interop/firestore_interop.dart'
    show
        Blob,
        FieldPath,
        FieldValue,
        GeoPoint,
        setLogLevel,
        SetOptions,
        Settings,
        SnapshotMetadata;

/// The Cloud Firestore service interface.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.Firestore>.
class Firestore extends JsObjectWrapper<firestore_interop.FirestoreJsImpl> {
  static final _expando = new Expando<Firestore>();

  /// Non-null App for this instance of firestore service.
  App get app => App.getInstance(jsObject.app);

  /// Creates a new Firestore from a [jsObject].
  static Firestore getInstance(firestore_interop.FirestoreJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new Firestore._fromJsObject(jsObject);
  }

  Firestore._fromJsObject(firestore_interop.FirestoreJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Creates a write batch, used for performing multiple writes
  /// as a single atomic operation.
  ///
  /// Returns non-null [WriteBatch] that can be used to atomically execute
  /// multiple writes.
  WriteBatch batch() => WriteBatch.getInstance(jsObject.batch());

  /// Gets a [CollectionReference] instance that refers to the collection
  /// at the specified path.
  /// The [collectionPath] parameter is a slash-separated path to a collection.
  ///
  /// Returns non-null [CollectionReference] instance.
  CollectionReference collection(String collectionPath) =>
      CollectionReference.getInstance(jsObject.collection(collectionPath));

  /// Gets a [DocumentReference] instance that refers to
  /// the document at the specified path.
  /// The [documentPath] parameter is a slash-separated path to a document.
  ///
  /// Returns non-null [DocumentReference] instance.
  DocumentReference doc(String documentPath) =>
      DocumentReference.getInstance(jsObject.doc(documentPath));

  /// Attempts to enable persistent storage, if possible.
  ///
  /// Must be called before any other methods (other than [settings()]).
  ///
  /// If this fails, [enablePersistence()] will reject the Future it returns.
  /// Note that even after this failure, the firestore instance will remain
  /// usable, however offline persistence will be disabled.
  ///
  /// There are several reasons why this can fail, which can be identified by
  /// the `code` on the error.
  /// * failed-precondition: The app is already open in another browser tab.
  /// * unimplemented: The browser is incompatible with the offline
  /// persistence implementation.
  ///
  /// Returns non-null [Future] that represents successfully enabling
  /// persistent storage.
  Future<Null> enablePersistence() =>
      handleThenable(jsObject.enablePersistence());

  /// Executes the given [updateFunction] and then attempts to commit the
  /// changes applied within the transaction. If any document read within
  /// the transaction has changed, Cloud Firestore retries
  /// the [updateFunction].
  /// If it fails to commit after 5 attempts, the transaction fails.
  ///
  /// Returns non-null [Future] if the transaction completed successfully
  /// or was explicitly aborted (the [updateFunction] returned a failed Future),
  /// the Future returned by the [updateFunction] is returned here.
  /// Else, if the transaction failed, a rejected Future with the corresponding
  /// failure error will be returned.
  Future runTransaction(updateFunction(Transaction transaction)) {
    var updateFunctionWrap = allowInterop((transaction) =>
        handleFutureWithMapper(
            updateFunction(Transaction.getInstance(transaction)), jsify));

    return handleThenableWithMapper(
        jsObject.runTransaction(updateFunctionWrap), dartify);
  }

  /// Specifies custom [Settings] to be used to configure the Firestore
  /// instance. Must be set before invoking any other methods.
  ///
  /// The [Settings] parameter is the settings for your Cloud Firestore instance.
  /// Value must not be null.
  void settings(firestore_interop.Settings settings) =>
      jsObject.settings(settings);

  /// Re-enables use of the network for this Firestore instance after a prior call to [disableNetwork].
  Future enableNetwork() => handleThenable(jsObject.enableNetwork());

  /// Disables network usage for this instance. It can be re-enabled via [enableNetwork].
  /// While the network is disabled, any snapshot listeners or get() calls will return results from cache,
  /// and any write operations will be queued until the network is restored.
  Future disableNetwork() => handleThenable(jsObject.disableNetwork());
}

/// A write batch, used to perform multiple writes as a single atomic unit.
///
/// A [WriteBatch] object can be acquired by calling the [Firestore.batch()]
/// function. It provides methods for adding writes to the write batch.
/// None of the writes are committed (or visible locally) until
/// [WriteBatch.commit()] is called.
///
/// Unlike transactions, write batches are persisted offline and therefore
/// are preferable when you don't need to condition your writes on read data.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.WriteBatch>.
class WriteBatch extends JsObjectWrapper<firestore_interop.WriteBatchJsImpl>
    with _Updatable {
  static final _expando = new Expando<WriteBatch>();

  /// Creates a new WriteBatch from a [jsObject].
  static WriteBatch getInstance(firestore_interop.WriteBatchJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new WriteBatch._fromJsObject(jsObject);
  }

  WriteBatch._fromJsObject(firestore_interop.WriteBatchJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Commits all of the writes in this write batch as a single atomic unit.
  ///
  /// Returns non-null [Future] that resolves once all of the writes in the
  /// batch have been successfully written to the backend as an atomic unit.
  /// Note that it won't resolve while you're offline.
  Future<Null> commit() => handleThenable(jsObject.commit());

  /// Deletes the document referred to by the provided [DocumentReference].
  ///
  /// [DocumentReference] is a reference to the document to be deleted.
  /// Value must not be null.
  ///
  /// Returns non-null [WriteBatch] instance. Used for chaining method calls.
  WriteBatch delete(DocumentReference documentRef) =>
      WriteBatch.getInstance(jsObject.delete(documentRef.jsObject));

  /// Writes to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created.
  /// If you pass [options], the provided data can be merged into
  /// the existing document.
  ///
  /// The [DocumentReference] parameter is a reference to the document to be
  /// created. Value must not be null.
  ///
  /// The [data] parameter is a Map of the fields and values for the document.
  /// Value must not be null.
  ///
  /// The optional [SetOptions] parameters is an object to configure the set
  /// behavior. Pass [: {merge: true} :] to only replace the values specified in
  /// the data argument. Fields omitted will remain untouched. Value may be null.
  ///
  /// Returns non-null [WriteBatch] instance. Used for chaining method calls.
  WriteBatch set(DocumentReference documentRef, Map<String, dynamic> data,
      [firestore_interop.SetOptions options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(documentRef.jsObject, jsify(data), options)
        : jsObject.set(documentRef.jsObject, jsify(data));
    return WriteBatch.getInstance(jsObjectSet);
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Nested fields can be updated by providing dot-separated field path strings
  /// or by providing [FieldPath] objects.
  ///
  /// The [DocumentReference] parameter is a reference to the document to
  /// be updated. Value must not be null.
  ///
  /// The [data] param is the Map containing all of the fields and values
  /// to update.
  ///
  /// The [fieldsAndValues] param is the List alternating between fields
  /// (as String or [FieldPath] objects) and values.
  ///
  /// Returns non-null [WriteBatch] instance used for chaining method calls.
  WriteBatch update(DocumentReference documentRef,
          {Map<String, dynamic> data,
          List< /*String|FieldPath|dynamic*/ dynamic> fieldsAndValues}) =>
      WriteBatch.getInstance(_wrapUpdateFunctionCall(
          jsObject, data, fieldsAndValues, documentRef));
}

/// A [DocumentReference] refers to a document location in a
/// Firestore database and can be used to write, read, or listen to the location.
/// The document at the referenced location may or may not exist.
///
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.DocumentReference>.
class DocumentReference
    extends JsObjectWrapper<firestore_interop.DocumentReferenceJsImpl>
    with _Updatable {
  static final _expando = new Expando<DocumentReference>();

  /// Non-null [Firestore] the document is in.
  /// This is useful for performing transactions, for example.
  Firestore get firestore => Firestore.getInstance(jsObject.firestore);

  /// The document's identifier within its collection.
  String get id => jsObject.id;

  /// Non-null [CollectionReference].
  /// The Collection this [DocumentReference] belongs to.
  CollectionReference get parent =>
      CollectionReference.getInstance(jsObject.parent);

  /// The document's path within its collection.
  String get path => jsObject.path;

  /// Creates a new DocumentReference from a [jsObject].
  static DocumentReference getInstance(
      firestore_interop.DocumentReferenceJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new DocumentReference._fromJsObject(jsObject);
  }

  DocumentReference._fromJsObject(
      firestore_interop.DocumentReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Gets a [CollectionReference] instance that refers to the collection at
  /// the specified path.
  ///
  /// The [collectionPath] parameter is a slash-separated path to a collection.
  ///
  /// Returns non-null [CollectionReference] instance.
  CollectionReference collection(String collectionPath) =>
      CollectionReference.getInstance(jsObject.collection(collectionPath));

  /// Deletes the document referred to by this [DocumentReference].
  ///
  /// Returns non-null [Future] that resolves once the document has been
  /// successfully deleted from the backend (Note that it won't resolve
  /// while you're offline).
  Future<Null> delete() => handleThenable(jsObject.delete());

  /// Reads the document referred to by this [DocumentReference].
  /// Note: [get()] attempts to provide up-to-date data when possible
  /// by waiting for data from the server, but it may return cached data or
  /// fail if you are offline and the server cannot be reached.
  ///
  /// Returns non-null [Future] containing non-null [DocumentSnapshot]
  /// that resolves with a [DocumentSnapshot] containing the current document
  /// contents.
  Future<DocumentSnapshot> get() =>
      handleThenableWithMapper(jsObject.get(), DocumentSnapshot.getInstance);

  StreamController<DocumentSnapshot> _onSnapshotController;
  StreamController<DocumentSnapshot> _onMetadataController;

  /// Attaches a listener for [DocumentSnapshot] events.
  Stream<DocumentSnapshot> get onSnapshot =>
      _createStream(_onSnapshotController);

  /// Attaches a listener for [DocumentSnapshot] events
  /// with [: {includeMetadataChanges: true} :] - raise an event even if only
  /// metadata of the document changed. Default is [:false:].
  Stream<DocumentSnapshot> get onMetadataChangesSnapshot => _createStream(
      _onMetadataController,
      new firestore_interop.DocumentListenOptions(
          includeMetadataChanges: true));

  Stream<DocumentSnapshot> _createStream(
      StreamController<DocumentSnapshot> controller,
      [firestore_interop.DocumentListenOptions options]) {
    if (controller == null) {
      var nextWrapper =
          allowInterop((firestore_interop.DocumentSnapshotJsImpl snapshot) {
        controller.add(DocumentSnapshot.getInstance(snapshot));
      });

      var errorWrapper = allowInterop((e) => controller.addError(e));

      ZoneCallback onSnapshotUnsubscribe;

      void startListen() {
        onSnapshotUnsubscribe = (options != null)
            ? jsObject.onSnapshot(options, nextWrapper, errorWrapper)
            : jsObject.onSnapshot(nextWrapper, errorWrapper);
      }

      void stopListen() {
        onSnapshotUnsubscribe();
        onSnapshotUnsubscribe = null;
      }

      controller = new StreamController<DocumentSnapshot>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return controller.stream;
  }

  /// Writes to the document referred to by this [DocumentReference].
  /// If the document does not exist yet, it will be created.
  /// If you pass [options], the provided data can be merged into the
  /// existing document.
  ///
  /// The [data] parameter is a Map of the fields and values for the
  /// document. Value must not be null.
  ///
  /// The optional [SetOptions] is an object to configure the set behavior.
  /// Pass [: {merge: true} :] to only replace the values specified in the data
  /// argument. Fields omitted will remain untouched. Value may be null.
  ///
  /// Returns non-null [Future] that resolves once the data has been successfully
  /// written to the backend. (Note that it won't resolve while you're offline).
  Future<Null> set(Map<String, dynamic> data,
      [firestore_interop.SetOptions options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(jsify(data), options)
        : jsObject.set(jsify(data));
    return handleThenable(jsObjectSet);
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Nested fields can be updated by providing dot-separated field path strings
  /// or by providing [FieldPath] objects.
  ///
  /// The [data] param is the Map containing all of the fields and values
  /// to update.
  ///
  /// The [fieldsAndValues] param is the List alternating between fields
  /// (as String or [FieldPath] objects) and values.
  ///
  /// Returns non-null [Future] that resolves once the data has been successfully
  /// written to the backend (Note that it won't resolve while you're offline).
  Future<Null> update(
          {Map<String, dynamic> data,
          List< /*String|FieldPath|dynamic*/ dynamic> fieldsAndValues}) =>
      handleThenable(_wrapUpdateFunctionCall(jsObject, data, fieldsAndValues));
}

/// A Query refers to a Query which you can read or listen to.
/// You can also construct refined [Query] objects by adding filters
/// and ordering.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.Query>.
class Query<T extends firestore_interop.QueryJsImpl>
    extends JsObjectWrapper<T> {
  /// Non-null [Firestore] for the Cloud Firestore database
  /// (useful for performing transactions, etc.).
  Firestore get firestore => Firestore.getInstance(jsObject.firestore);

  /// Creates a new Query from a [jsObject].
  Query.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Creates a new [Query] where the results end at the provided document
  /// (inclusive). The end position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy
  /// of this query.
  ///
  /// The [DocumentSnapshot] parameter is the snapshot of the document you want
  /// the query to end at. Or the list of [fieldValues] to
  /// end this query at, in order of the query's order by.
  ///
  /// Returns non-null created [Query].
  Query endAt({DocumentSnapshot snapshot, List<dynamic> fieldValues}) =>
      new Query.fromJsObject(
          _wrapPaginatingFunctionCall("endAt", snapshot, fieldValues));

  /// Creates a new [Query] where the results end before the provided document
  /// (exclusive). The end position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// The [DocumentSnapshot] parameter is the snapshot of the document you want
  /// the query to end before. Or the list of [fieldValues] to
  /// end this query before, in order of the query's order by.
  ///
  /// Returns non-null created [Query].
  Query endBefore({DocumentSnapshot snapshot, List<dynamic> fieldValues}) =>
      new Query.fromJsObject(
          _wrapPaginatingFunctionCall("endBefore", snapshot, fieldValues));

  /// Executes the query and returns the results as a [QuerySnapshot].
  ///
  /// Returns non-null [Future] that will be resolved with the results of the
  /// query.
  Future<QuerySnapshot> get() =>
      handleThenableWithMapper(jsObject.get(), QuerySnapshot.getInstance);

  /// Creates a new [Query] where the results are limited to the specified
  /// number of documents.
  ///
  /// The [limit] parameter is the maximum number of items to return.
  ///
  /// Returns non-null created [Query].
  Query limit(num limit) => new Query.fromJsObject(jsObject.limit(limit));

  StreamController<QuerySnapshot> _onSnapshotController;
  StreamController<QuerySnapshot> _onDocumentMetadataController;
  StreamController<QuerySnapshot> _onQueryMetadataController;

  /// Attaches a listener for [QuerySnapshot] events.
  Stream<QuerySnapshot> get onSnapshot => _createStream(_onSnapshotController);

  /// Attaches a listener for [QuerySnapshot] events
  /// with [: {includeDocumentMetadataChanges: true} :] - raise an event even
  /// if only metadata of a document in the query results changes
  /// (for example, one of the [DocumentSnapshot.metadata] properties
  /// on one of the documents). Default is [:false:].
  Stream<QuerySnapshot> get onDocumentMetadataChangesSnapshot => _createStream(
      _onDocumentMetadataController,
      new firestore_interop.QueryListenOptions(
          includeDocumentMetadataChanges: true));

  /// Attaches a listener for [QuerySnapshot] events
  /// with [: {includeQueryMetadataChanges: true} :] - raise an event even
  /// if only metadata changes (for example, one of the
  /// [QuerySnapshot.metadata] properties). Default is [:false:].
  Stream<QuerySnapshot> get onQueryMetadataChangesSnapshot => _createStream(
      _onQueryMetadataController,
      new firestore_interop.QueryListenOptions(
          includeQueryMetadataChanges: true));

  Stream<QuerySnapshot> _createStream(
      StreamController<QuerySnapshot> controller,
      [firestore_interop.QueryListenOptions options]) {
    if (controller == null) {
      var nextWrapper =
          allowInterop((firestore_interop.QuerySnapshotJsImpl snapshot) {
        controller.add(QuerySnapshot.getInstance(snapshot));
      });

      var errorWrapper = allowInterop((e) => controller.addError(e));

      ZoneCallback onSnapshotUnsubscribe;

      void startListen() {
        onSnapshotUnsubscribe = (options != null)
            ? jsObject.onSnapshot(options, nextWrapper, errorWrapper)
            : jsObject.onSnapshot(nextWrapper, errorWrapper);
      }

      void stopListen() {
        onSnapshotUnsubscribe();
        onSnapshotUnsubscribe = null;
      }

      controller = new StreamController<QuerySnapshot>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return controller.stream;
  }

  /// Creates a new [Query] where the results are sorted by the specified field,
  /// in descending or ascending order.
  ///
  /// The [fieldPath] parameter is a String or [FieldPath] to sort by.
  ///
  /// The optional [directionStr] parameter is a direction to sort by
  /// ([:asc:] or [:desc:]). If not specified, the default order is ascending.
  ///
  /// Returns non-null created [Query].
  Query orderBy(/*String|FieldPath*/ fieldPath,
      [String /*'desc'|'asc'*/ directionStr]) {
    var jsObjectOrderBy = (directionStr != null)
        ? jsObject.orderBy(fieldPath, directionStr)
        : jsObject.orderBy(fieldPath);
    return new Query.fromJsObject(jsObjectOrderBy);
  }

  /// Creates a new [Query] where the results start after the provided document
  /// (exclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the
  /// [orderBy] of this query.
  ///
  /// The [DocumentSnapshot] parameter is the snapshot of the document you want
  /// the query to start after. Or the list of [fieldValues] to
  /// start this query after, in order of the query's order by.
  ///
  /// Returns non-null created [Query].
  ///
  ///     firestore().collection("cities")
  ///         .orderBy("name")
  ///         .orderBy("state")
  ///         .startAfter(fieldValues: ["Springfield", "Missouri"]);
  Query startAfter({DocumentSnapshot snapshot, List<dynamic> fieldValues}) =>
      new Query.fromJsObject(
          _wrapPaginatingFunctionCall("startAfter", snapshot, fieldValues));

  /// Creates a new [Query] where the results start at the provided document
  /// (inclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// the query.
  ///
  /// The [DocumentSnapshot] parameter is the snapshot of the document you want
  /// the query to start at. Or the list of [fieldValues] to
  /// start this query at, in order of the query's order by.
  ///
  /// Returns non-null created [Query].
  ///
  ///     firestore().collection("cities")
  ///         .orderBy("name")
  ///         .orderBy("state")
  ///         .startAt(fieldValues: ["Springfield", "Missouri"]);
  Query startAt({DocumentSnapshot snapshot, List<dynamic> fieldValues}) =>
      new Query.fromJsObject(
          _wrapPaginatingFunctionCall("startAt", snapshot, fieldValues));

  /// Creates a new [Query] that returns only documents that include the
  /// specified fields and where the values satisfy the constraints provided.
  ///
  /// The [fieldPath] parameter is a String or non-null [FieldPath] to compare.
  ///
  /// The [opStr] parameter is the operation string
  /// (e.g [:<:], [:<=:], [:==:], [:>:], [:>=:]).
  ///
  /// The [value] parameter is the value for comparison.
  ///
  /// Returns non-null created [Query].
  Query where(/*String|FieldPath*/ fieldPath,
          String /*'<'|'<='|'=='|'>='|'>'*/ opStr, value) =>
      new Query.fromJsObject(jsObject.where(fieldPath, opStr, jsify(value)));

  /// Calls js paginating [method] with [DocumentSnapshot] or List of [fieldValues].
  /// We need to call this method in all paginating methods to fix that Dart
  /// doesn't support varargs - we need to use [List] to call js function.
  _wrapPaginatingFunctionCall(
      String method, DocumentSnapshot snapshot, List<dynamic> fieldValues) {
    if (snapshot == null && fieldValues == null) {
      throw new ArgumentError(
          "Please provide either snapshot or fieldValues parameter.");
    }

    List<dynamic> args = (snapshot != null)
        ? [snapshot.jsObject]
        : fieldValues.map(jsify).toList();
    return callMethod(jsObject, method, args);
  }
}

/// A [CollectionReference] class can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from [Query]).
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.CollectionReference>.
class CollectionReference<T extends firestore_interop.CollectionReferenceJsImpl>
    extends Query<T> {
  static final _expando = new Expando<CollectionReference>();

  /// The collection's identifier.
  String get id => jsObject.id;

  /// Nullable reference to the containing [DocumentReference] if this is
  /// a subcollection. If this isn't a subcollection, the reference is [:null:].
  DocumentReference get parent =>
      DocumentReference.getInstance(jsObject.parent);

  /// The collection's path.
  String get path => jsObject.path;

  /// Creates a new CollectionReference from a [jsObject].
  static CollectionReference getInstance(
      firestore_interop.CollectionReferenceJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??=
        new CollectionReference._fromJsObject(jsObject);
  }

  /// Creates a new CollectionReference
  factory CollectionReference() => new CollectionReference._fromJsObject(
      new firestore_interop.CollectionReferenceJsImpl());

  CollectionReference._fromJsObject(
      firestore_interop.CollectionReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds a new document to this collection with the specified [data],
  /// assigning it a document ID automatically.
  ///
  /// The [data] parameter must not be null.
  ///
  /// Returns non-null [Future] that resolves with a [DocumentReference]
  /// pointing to the newly created document after it has been written
  /// to the backend.
  Future<DocumentReference> add(Map<String, dynamic> data) =>
      handleThenableWithMapper(
          jsObject.add(jsify(data)), DocumentReference.getInstance);

  /// Gets a [DocumentReference] for the document within the collection
  /// at the specified path. If no [documentPath] is specified,
  /// an automatically-generated unique ID will be used for the
  /// returned [DocumentReference].
  ///
  /// The optional [documentPath] parameter is a slash-separated path to
  /// a document.
  ///
  /// Returns non-null [DocumentReference].
  DocumentReference doc([String documentPath]) {
    var jsObjectDoc =
        (documentPath != null) ? jsObject.doc(documentPath) : jsObject.doc();
    return DocumentReference.getInstance(jsObjectDoc);
  }

  bool isEqual(CollectionReference other) => jsObject.isEqual(other.jsObject);
}

/// A [DocumentChange] represents a change to the documents matching a query.
/// It contains the document affected and the type of change that occurred.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.DocumentChange>.
class DocumentChange
    extends JsObjectWrapper<firestore_interop.DocumentChangeJsImpl> {
  static final _expando = new Expando<DocumentChange>();

  /// Type of the change: [:added:], [:removed:] or [:modified:].
  String get type => jsObject.type;

  /// The document affected by this change.
  DocumentSnapshot get doc => DocumentSnapshot.getInstance(jsObject.doc);

  /// The index of the changed document in the result set immediately prior to
  /// this [DocumentChange] (i.e. supposing that all prior DocumentChange
  /// objects have been applied). Is -1 for 'added' events.
  num get oldIndex => jsObject.oldIndex;

  /// The index of the changed document in the result set immediately after
  /// this [DocumentChange] (i.e. supposing that all prior DocumentChange
  /// objects and the current DocumentChange object have been applied).
  /// Is -1 for 'removed' events.
  num get newIndex => jsObject.newIndex;

  /// Creates a new DocumentChange from a [jsObject].
  static DocumentChange getInstance(
      firestore_interop.DocumentChangeJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new DocumentChange._fromJsObject(jsObject);
  }

  DocumentChange._fromJsObject(firestore_interop.DocumentChangeJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

/// A [DocumentSnapshot] contains data read from a document in your
/// Cloud Firestore database. The data can be extracted with [data()] or
/// [get(<field>)] to get a specific field.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.DocumentSnapshot>.
class DocumentSnapshot
    extends JsObjectWrapper<firestore_interop.DocumentSnapshotJsImpl> {
  static final _expando = new Expando<DocumentSnapshot>();

  /// Signals whether or not the data exists. [:true:] if the document exists.
  bool get exists => jsObject.exists;

  /// Provides the document's ID.
  String get id => jsObject.id;

  /// Non-null metadata about the [DocumentSnapshot], including information
  /// about its source and local modifications.
  firestore_interop.SnapshotMetadata get metadata => jsObject.metadata;

  /// Non-null [DocumentReference] for the document included
  /// in the [DocumentSnapshot].
  DocumentReference get ref => DocumentReference.getInstance(jsObject.ref);

  /// Creates a new DocumentSnapshot from a [jsObject].
  static DocumentSnapshot getInstance(
      firestore_interop.DocumentSnapshotJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new DocumentSnapshot._fromJsObject(jsObject);
  }

  DocumentSnapshot._fromJsObject(
      firestore_interop.DocumentSnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Retrieves all fields in the document as a Map.
  ///
  /// Returns non-null [Map] containing all fields in the specified
  /// document.
  Map<String, dynamic> data() => dartify(jsObject.data());

  /// Retrieves the field specified by [fieldPath] parameter at the specified
  /// field location or [:null:] if no such field exists in the document.
  ///
  /// The [fieldPath] is the String or [FieldPath] - the path
  /// (e.g. 'foo' or 'foo.bar') to a specific field.
  dynamic get(/*String|FieldPath*/ fieldPath) =>
      dartify(jsObject.get(fieldPath));

  /// Returns `true` if this [DocumentSnapshot] is equal to the provided one.
  bool isEqual(DocumentSnapshot other) => jsObject.isEqual(other.jsObject);
}

/// A [QuerySnapshot] contains zero or more [DocumentSnapshot] objects
/// representing the results of a query. The documents can be accessed as
/// an array via the docs property or enumerated using the [forEach()] method.
/// The number of documents can be determined via the [empty] and [size] properties.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.QuerySnapshot>.
class QuerySnapshot
    extends JsObjectWrapper<firestore_interop.QuerySnapshotJsImpl> {
  static final _expando = new Expando<QuerySnapshot>();

  /// Non-null list of the documents that changed since the last snapshot.
  /// If this is the first snapshot, all documents will be in the list as
  /// added changes.
  List<DocumentChange> get docChanges =>
      jsObject.docChanges.map(DocumentChange.getInstance).toList();

  /// Non-null list of all the documents.
  List<DocumentSnapshot> get docs =>
      jsObject.docs.map(DocumentSnapshot.getInstance).toList();

  /// [:true:] if there are no documents.
  bool get empty => jsObject.empty;

  /// Non-null metadata about this snapshot, concerning its source and if it
  /// has local modifications.
  firestore_interop.SnapshotMetadata get metadata => jsObject.metadata;

  /// The [Query] you called [Query.get] or [Query.onSnapshot] on to get the
  /// [QuerySnapshot].
  Query get query => new Query.fromJsObject(jsObject.query);

  /// The number of documents.
  num get size => jsObject.size;

  /// Creates a new QuerySnapshot from a [jsObject].
  static QuerySnapshot getInstance(
      firestore_interop.QuerySnapshotJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new QuerySnapshot._fromJsObject(jsObject);
  }

  QuerySnapshot._fromJsObject(firestore_interop.QuerySnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Enumerates all of the documents in the [QuerySnapshot].
  void forEach(callback(DocumentSnapshot snapshot)) {
    var callbackWrap =
        allowInterop((s) => callback(DocumentSnapshot.getInstance(s)));
    return jsObject.forEach(callbackWrap);
  }

  /// Returns `true` if this [QuerySnapshot] is equal to the provided one.
  bool isEqual(QuerySnapshot other) => jsObject.isEqual(other.jsObject);
}

/// A reference to a transaction.
/// The [Transaction] object passed to a transaction's [updateFunction()]
/// provides the methods to read and write data within the transaction context.
/// See: [Firestore.runTransaction()].
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.Transaction>.
class Transaction extends JsObjectWrapper<firestore_interop.TransactionJsImpl>
    with _Updatable {
  static final _expando = new Expando<Transaction>();

  /// Creates a new Transaction from a [jsObject].
  static Transaction getInstance(firestore_interop.TransactionJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new Transaction._fromJsObject(jsObject);
  }

  Transaction._fromJsObject(firestore_interop.TransactionJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Deletes the document referred to by the provided [DocumentReference].
  ///
  /// The [DocumentReference] parameter is a reference to the document to be
  /// deleted. Value must not be null.
  ///
  /// Returns non-null [Transaction] used for chaining method calls.
  Transaction delete(DocumentReference documentRef) =>
      Transaction.getInstance(jsObject.delete(documentRef.jsObject));

  /// Reads the document referenced by the provided [DocumentReference].
  ///
  /// The [DocumentReference] parameter is a reference to the document to be
  /// retrieved. Value must not be null.
  ///
  /// Returns non-null [Future] of the read data in a [DocumentSnapshot].
  Future<DocumentSnapshot> get(DocumentReference documentRef) =>
      handleThenableWithMapper(
          jsObject.get(documentRef.jsObject), DocumentSnapshot.getInstance);

  /// Writes to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created.
  /// If you pass [options], the provided data can be merged into the existing
  /// document.
  ///
  /// The [DocumentReference] parameter is a reference to the document to be
  /// created. Value must not be null.
  ///
  /// The [data] paramater is object of the fields and values for
  /// the document. Value must not be null.
  ///
  /// The optional [SetOptions] is an object to configure the set behavior.
  /// Pass [: {merge: true} :] to only replace the values specified in the
  /// data argument. Fields omitted will remain untouched.
  /// Value must not be null.
  ///
  /// Returns non-null [Transaction] used for chaining method calls.
  Transaction set(DocumentReference documentRef, Map<String, dynamic> data,
      [firestore_interop.SetOptions options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(documentRef.jsObject, jsify(data), options)
        : jsObject.set(documentRef.jsObject, jsify(data));
    return Transaction.getInstance(jsObjectSet);
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  /// The update will fail if applied to a document that does not exist.
  /// The value must not be null.
  ///
  /// Nested fields can be updated by providing dot-separated field path strings
  /// or by providing [FieldPath] objects.
  ///
  /// The [data] param is the object containing all of the fields and values
  /// to update.
  ///
  /// The [fieldsAndValues] param is the List alternating between fields
  /// (as String or [FieldPath] objects) and values.
  ///
  /// Returns non-null [Transaction] instance used for chaining method calls.
  Transaction update(DocumentReference documentRef,
          {Map<String, dynamic> data,
          List< /*String|FieldPath|dynamic*/ dynamic> fieldsAndValues}) =>
      Transaction.getInstance(_wrapUpdateFunctionCall(
          jsObject, data, fieldsAndValues, documentRef));
}

/// Mixin class for all classes with the [update()] method.
/// We need to call [_wrapUpdateFunctionCall()] in all [update()] methods
/// to fix that Dart doesn't support varargs - we need to use [List]
/// to call js function.
abstract class _Updatable {
  /// Calls js [:update():] method on [jsObject] with [data] or list of
  /// [fieldsAndValues] and optionally [documentRef].
  _wrapUpdateFunctionCall(jsObject, Map<String, dynamic> data,
      List< /*String|FieldPath|dynamic*/ dynamic> fieldsAndValues,
      [DocumentReference documentRef]) {
    if (data == null && fieldsAndValues == null) {
      throw new ArgumentError(
          "Please provide either data or fieldsAndValues parameter.");
    }

    List<dynamic> args = (data != null)
        ? [jsify(data)]
        : fieldsAndValues
            .map((f) => (f is firestore_interop.FieldPath) ? f : jsify(f))
            .toList();

    // documentRef has to be the first parameter in list of args
    if (documentRef != null) {
      args.insert(0, documentRef.jsObject);
    }
    return callMethod(jsObject, "update", args);
  }
}
