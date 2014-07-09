run = (key, message, cipher) ->
  if containsInvalidCharacters(key) or containsInvalidCharacters(message)
    throw "Invalid characters in key or message."

  fullKey = matchKeyLengthToMessage key, message.length

  # This translates to A in UNICODE
  firstCharacterCodeInAlphabet = 65
  alphabetSize = 26

  fullKeyCharacterCodes = fullKey.split("").map (character) -> character.charCodeAt 0
  fullMessageCharacterCodes = message.split("").map (character) -> character.charCodeAt 0

  cipherCharacterCodes = for keyCharacterCode, i in fullKeyCharacterCodes
    messageCharacterCode = fullMessageCharacterCodes[i]

    # The Character Codes in Javascript UNICODE do not match to 1-26 for A-Z so this will offset the character codes back.
    firstCharacterCodeOffset = firstCharacterCodeInAlphabet - 1

    cipherCharacter = cipher(keyCharacterCode - firstCharacterCodeOffset, messageCharacterCode - firstCharacterCodeOffset, alphabetSize)

    # The last character Z will match to be 0 and needs to be set
    # as the last character.
    # TODO I am positive there is a workaround for this
    if cipherCharacter is 0
      cipherCharacter = alphabetSize

    cipherCharacter += firstCharacterCodeOffset

  String.fromCharCode.apply null, cipherCharacterCodes

containsInvalidCharacters = (string) ->
  /[^A-Z]/.test(string)

matchKeyLengthToMessage = (key, messageLength) ->
  keyCharacters = key.split("")

  if keyCharacters.length is 0
    throw "Key is blank."

  if messageLength is 0
    throw "Message is empty."

  fullKeyCharacters = for i in [0..messageLength-1]
    keyCharacters[i % keyCharacters.length]

  fullKeyCharacters.join ""

exports.run = run


runTests = ->
  assert = require 'assert'

  key = "CRYPTO"
  message = "WHATANICEDAYTODAY"

  messageLength = message.split("").length

  assert.equal matchKeyLengthToMessage(key, messageLength), "CRYPTOCRYPTOCRYPT", "Oops, key length mismatch"
  assert.throws (-> matchKeyLengthToMessage(key, 0)), "Blank Message"
  assert.throws (-> matchKeyLengthToMessage("", messageLength)), "Blank Key"

  assert containsInvalidCharacters("123A")
  assert not containsInvalidCharacters("ABC")

  assert.doesNotThrow (-> run(key, message, ->))
  assert.throws (-> run("", message, -> )), "Invalid Key"
  assert.throws (-> run(key, "", -> )), "Invalid Message"
  assert.throws (-> run("BLA2", message, ->)), "Invalid Characters Key"
  assert.throws (-> run(key, 0, ->)), "Invalid Characters Message"

runTests()
