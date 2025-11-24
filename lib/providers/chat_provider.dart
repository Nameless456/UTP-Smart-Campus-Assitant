import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/api/api_service.dart';
import 'package:flutter_gemini/constant.dart';
import 'package:flutter_gemini/hive/chat_history.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:flutter_gemini/hive/user_model.dart';
import 'package:flutter_gemini/models/message.dart';
import 'package:flutter_gemini/services/map_navigation_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  //list of messages
  final List<Message> _inChatMessages = [];

  //page controller
  final PageController _pageController = PageController();

  // images file list
  List<XFile>? _imagesFileList = [];

  //index of the current screen
  int _currentIndex = 0;

  // current chatId
  String _currentChatId = "";

  // initialize generative model
  GenerativeModel? _model;

  //initialize text model
  GenerativeModel? _textModel;

  // initialize vision model
  GenerativeModel? _visionModel;

  // current model
  String _modelType = 'gemini-pro';

  // loading bool
  bool _isLoading = false;

  // navigation service
  final MapNavigationService _navigationService = MapNavigationService();

  // setters

  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from hive database
    final messageFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messageFromDB) {
      if (_inChatMessages.contains(message)) {
        log('message already exists');
        continue;
      }

      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // load the messages from db
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    // open the box of this chatID
    await Hive.openBox('${Constant.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constant.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));

      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  // set file list
  void setImagesFileList({required List<XFile>? listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  // set current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // function to set the model base on bool - isTextOnly
  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model =
          _textModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.5-flash'),
            apiKey: ApiService.apikey,
          );
    } else {
      _model =
          _visionModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.5-flash'),
            apiKey: ApiService.apikey,
          );
    }
    notifyListeners();
  }

  // set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // set current chatId
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  // send message to gemini and get the streamed response
  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
    required BuildContext context,
  }) async {
    // Check if this is a navigation request
    if (_navigationService.isNavigationRequest(message)) {
      // Get navigation response with distance info
      final navResponse = await _navigationService.getNavigationResponse(
        message,
      );

      if (navResponse != null) {
        // set the model
        await setModel(isTextOnly: isTextOnly);

        // set loading to true
        setLoading(value: true);

        // get the chatid
        String chatId = getChatID();

        // get the imagesUrls
        List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

        // user message
        final userMessage = Message(
          messageId: const Uuid().v4(),
          chatId: chatId,
          role: Role.user,
          message: StringBuffer(message),
          imageUrls: imagesUrls,
          timeSent: DateTime.now(),
        );

        // add user message to chat
        _inChatMessages.add(userMessage);
        notifyListeners();

        if (currentChatId.isEmpty) {
          setCurrentChatId(newChatId: chatId);
        }

        // Create assistant response with navigation info
        final assistantMessage = userMessage.copyWith(
          messageId: const Uuid().v4(),
          message: StringBuffer(navResponse),
          timeSent: DateTime.now(),
          role: Role.assistant,
        );

        // add assistant message to chat
        _inChatMessages.add(assistantMessage);
        notifyListeners();

        // set loading to false
        setLoading(value: false);

        // Open the map
        await _navigationService.handleNavigationCommand(context, message);

        return;
      }
    }

    // Regular message flow (non-navigation)
    // set the model
    await setModel(isTextOnly: isTextOnly);

    // set loading to true
    setLoading(value: true);

    // get the chatid
    String chatId = getChatID();

    // list of history messages
    List<Content> history = [];

    // get the chat history
    history = await getChatHistory(chatId: chatId);

    // get the imagesUrls
    List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

    // user message
    final userMessage = Message(
      messageId: const Uuid().v4(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imageUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

    // add this messahe to the list on inChatMessages
    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    // send message to the model and wait for the response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
    );
  }

  // send message to the model and wait for the response
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
  }) async {
    // start the chat session - only send history is its text-only
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    // get content
    final content = await getContent(message: message, isTextOnly: isTextOnly);

    // assistant message
    final assistantMessage = userMessage.copyWith(
      messageId: const Uuid().v4(),
      message: StringBuffer(),
      timeSent: DateTime.now(),
      role: Role.assistant,
    );

    // add this message to the list on inChatMessages
    _inChatMessages.add(assistantMessage);
    notifyListeners();

    // wait for stream response
    chatSession
        .sendMessageStream(content)
        .asyncMap((event) {
          return event;
        })
        .listen(
          (event) {
            _inChatMessages
                .firstWhere(
                  (element) =>
                      element.messageId == assistantMessage.messageId &&
                      element.role == Role.assistant,
                )
                .message
                .write(event.text);
            notifyListeners();
          },
          onDone: () {
            // save message to hive db

            // set loading to false
            setLoading(value: false);
          },
        )
        .onError((error, stackTrace) {
          // log the error for debugging
          log('Error sending message: $error');
          log('Stack trace: $stackTrace');
          // set loading to false
          setLoading(value: false);
        });
  }

  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      return Content.text(message);
      // generate from text only input
    } else {
      final imageFuture = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);
      final imageBytes = await Future.wait(imageFuture!);

      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpg', Uint8List.fromList(bytes)))
          .toList();

      return Content.model([prompt, ...imageParts]);
    }
  }

  // get the imagesUrls
  List<String> getImagesUrls({required bool isTextOnly}) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getChatHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in _inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }

    return history;
  }

  String getChatID() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  // getters
  List<Message> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile>? get imagesFileList => _imagesFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  GenerativeModel? get model => _model;
  GenerativeModel? get textModel => _textModel;
  GenerativeModel? get visionModel => _visionModel;
  String get modelType => _modelType;
  bool get isLoading => _isLoading;

  // init Hive box
  static intHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constant.geminiDB);

    //register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      //open the chat history box
      await Hive.openBox<ChatHistory>(Constant.chatHistoryBox);
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constant.userBox);
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constant.settingsBox);
    }
  }
}
