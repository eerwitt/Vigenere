cipher = (key, message, cipher) ->
  if containsInvalidKeyCharacters(key) or containsInvalidMessageCharacters(message)
    throw "Invalid characters in key or message."

  fullKey = matchKeyLengthToMessage key, message.length

  alphabetSize = 26

  fullKeyCharacterCodes = fullKey.split("").map (character) -> character.charCodeAt 0
  fullMessageCharacterCodes = message.split("").map (character) -> character.charCodeAt 0

  cipherCharacterCodes = for keyCharacterCode, i in fullKeyCharacterCodes
    messageAlphabetCharacterCode = convertUnicodeCharacterCodeToAlphabet fullMessageCharacterCodes[i]
    keyAlphabetCharacterCode = convertUnicodeCharacterCodeToAlphabet keyCharacterCode

    cipherAlphabetCharacter = cipher(
      keyAlphabetCharacterCode,
      messageAlphabetCharacterCode,
      alphabetSize)

    # The last character Z will match to be 0 and needs to be set
    # as the last character.
    # TODO I am positive there is a workaround for this
    if cipherAlphabetCharacter is 0
      cipherAlphabetCharacter = alphabetSize

    cipherCharacter = convertAlphabetCharacterCodeToUnicode cipherAlphabetCharacter

  String.fromCharCode.apply null, cipherCharacterCodes

# The Character Codes in Javascript UNICODE do not match to 1-26 for A-Z so this will offset the character codes back.
# This translates to A in UNICODE 65
convertUnicodeCharacterCodeToAlphabet = (code, unicodeOffset=64) ->
  code - unicodeOffset

convertAlphabetCharacterCodeToUnicode = (code, unicodeOffset=64) ->
  code + unicodeOffset

containsInvalidKeyCharacters = (string) ->
  /[^A-Z]/.test(string)

containsInvalidMessageCharacters = (string) ->
  containsInvalidKeyCharacters string

matchKeyLengthToMessage = (key, messageLength) ->
  keyCharacters = key.split("")

  if keyCharacters.length is 0
    throw "Key is blank."

  if messageLength is 0
    throw "Message is empty."

  fullKeyCharacters = for i in [0..messageLength-1]
    keyCharacters[i % keyCharacters.length]

  fullKeyCharacters.join ""


#############################################
##              Actual Code                ##
#############################################
key = "CRYPTO"
message = "WHATANICEDAYTODAY"

vigenèreEncrypt = (key, message) ->
  cipher key, message, (keyCharacterCode, messageCharacterCode, alphabetSize) ->
    (keyCharacterCode + messageCharacterCode) % alphabetSize

vigenèreDecrypt = (key, encryptedMessage) ->
  cipher key, encryptedMessage, (keyCharacterCode, messageCharacterCode, alphabetSize) ->
    (messageCharacterCode - keyCharacterCode + alphabetSize) % alphabetSize

encryptedMessage = vigenèreEncrypt(key, message)
decryptedMessage = vigenèreDecrypt(key, encryptedMessage)

console.log """
  Encrypting #{message} with a key of #{key} using Vigenère cipher.
  Encrypted message is #{ encryptedMessage }.
  Decrypted message is #{ decryptedMessage }.
"""


#############################################
##                 Tests                   ##
#############################################
runTests = ->
  assert = require 'assert'

  key = "CRYPTO"
  message = "WHATANICEDAYTODAY"

  messageLength = message.split("").length

  assert.equal vigenèreEncrypt(key, message), "ZZZJUCLUDTUNWGCQS"
  assert.equal vigenèreEncrypt("ABC", "ABC"), "BDF"
  assert.equal vigenèreEncrypt("ABC", "A"), "B"
  assert.equal vigenèreEncrypt("Z", "ZAZ"), "ZAZ" #Interesting
  assert.equal vigenèreEncrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "BDFHJLNPRTVXZBDFHJLNPRTVXZ"
  assert.equal vigenèreEncrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ZZZZZZZZZZZZZZZZZZZZZZZZZZ"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  assert.equal vigenèreDecrypt(key, "ZZZJUCLUDTUNWGCQS"), message
  assert.equal vigenèreDecrypt("ABC", "BDF"), "ABC"
  assert.equal vigenèreDecrypt("ABC", "B"), "A"
  assert.equal vigenèreDecrypt("Z", "ZAZ"), "ZAZ" #Interesting
  assert.equal vigenèreDecrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "BDFHJLNPRTVXZBDFHJLNPRTVXZ"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  assert.equal vigenèreDecrypt("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "ZZZZZZZZZZZZZZZZZZZZZZZZZZ" # Hehe sweet

  assert.equal matchKeyLengthToMessage(key, messageLength), "CRYPTOCRYPTOCRYPT", "Oops, key length mismatch"
  assert.throws (-> matchKeyLengthToMessage(key, 0)), "Blank Message"
  assert.throws (-> matchKeyLengthToMessage("", messageLength)), "Blank Key"

  assert containsInvalidKeyCharacters("123A")
  assert not containsInvalidKeyCharacters("ABC")

  assert containsInvalidMessageCharacters("123A")
  assert not containsInvalidMessageCharacters("ABC")

  assert.equal convertUnicodeCharacterCodeToAlphabet(65), 1
  assert.equal convertAlphabetCharacterCodeToUnicode(1), 65

  assert.doesNotThrow (-> cipher(key, message, ->))
  assert.throws (-> cipher("", message, -> )), "Invalid Key"
  assert.throws (-> cipher(key, "", -> )), "Invalid Message"
  assert.throws (-> cipher("BLA2", message, ->)), "Invalid Characters Key"
  assert.throws (-> cipher(key, 0, ->)), "Invalid Characters Message"

runTests()
