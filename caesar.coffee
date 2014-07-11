cipher = (shift, message, alphabetSize, cipher) ->
  unless shift? and message? and message.length > 0
    throw "Invalid message or shift."

  if containsInvalidMessageCharacters(message) or containsInvalidShiftCharacters(shift)
    throw "Invalid characters in shift or message."


  cipherCharacterCodes = for character in convertToAlphabetKeyCodes message
    cipherCharacter = cipher character, shift

    # TODO I am positive there is a workaround for this
    if cipherCharacter is 0
      cipherCharacter = alphabetSize

    convertToUnicodeFromAlphabetCode cipherCharacter

  String.fromCharCode.apply null, cipherCharacterCodes

convertToAlphabetKeyCodes = (message, unicodeOffset=64) ->
  message.split("").map (character) -> character.charCodeAt(0) - unicodeOffset

convertToUnicodeFromAlphabetCode = (alphabetCode, unicodeOffset=64) ->
  alphabetCode + unicodeOffset

containsInvalidMessageCharacters = (string) ->
  /[^A-Z]/.test(string)

containsInvalidShiftCharacters = (shift) ->
  parseInt(shift) isnt shift

#############################################
##              Actual Code                ##
#############################################
rightShift = -3
message = "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"

caesarEncrypt = (shift, message, alphabetSize=26) ->
  shift += alphabetSize while shift < 0

  cipher shift, message, alphabetSize, (character, shift) ->
    (character + shift) % alphabetSize

caesarDecrypt = (shift, message, alphabetSize=26) ->
  shift -= alphabetSize while shift > 0

  cipher shift, message, alphabetSize, (character, shift) ->
    (character - shift) % alphabetSize

encryptedMessage = caesarEncrypt rightShift, message
decryptedMessage = caesarDecrypt rightShift, encryptedMessage

console.log """
  Encrypting #{message} with a shift of #{-3} using Caesar "Cipher".
  Encrypted message is #{encryptedMessage}.
  Decrypted message is #{decryptedMessage}.
"""

#############################################
##                 Tests                   ##
#############################################
runTests = ->
  assert = require 'assert'
  rightShift = -3
  message = "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"
  alphabetSize = 26

  assert.equal caesarEncrypt(-3, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "XYZABCDEFGHIJKLMNOPQRSTUVW"
  assert.equal caesarEncrypt(3, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "DEFGHIJKLMNOPQRSTUVWXYZABC"
  assert.equal caesarEncrypt(245, "ABC"), "LMN"
  assert.equal caesarEncrypt(-245, "ABC"), "PQR"
  assert.equal caesarEncrypt(-3, "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"), "QEBNRFZHYOLTKCLUGRJMPLSBOQEBIXWVALD"

  assert.equal caesarDecrypt(-3, "XYZABCDEFGHIJKLMNOPQRSTUVW"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  assert.equal caesarDecrypt(3, "DEFGHIJKLMNOPQRSTUVWXYZABC"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  assert.equal caesarDecrypt(245, "LMN"), "ABC"
  assert.equal caesarDecrypt(-245, "LMN"), "WXY"

  assert containsInvalidMessageCharacters("123A")
  assert not containsInvalidMessageCharacters("ABC")

  assert containsInvalidShiftCharacters("123A")
  assert not containsInvalidShiftCharacters(2)

  assert.deepEqual convertToAlphabetKeyCodes("ABC"), [1, 2, 3]
  assert.deepEqual convertToAlphabetKeyCodes("Z"), [26]

  assert.equal convertToUnicodeFromAlphabetCode(1), 65
  assert.equal convertToUnicodeFromAlphabetCode(26), 90

  assert.doesNotThrow (-> cipher(rightShift, message, alphabetSize, ->))
  assert.throws (-> cipher(null, message, alphabetSize, ->)), "Invalid shift."
  assert.throws (-> cipher(rightShift, "", alphabetSize, ->)), "Invalid message."
  assert.throws (-> cipher("abc", message, alphabetSize, ->)), "Invalid shift."
  assert.throws (-> cipher(rightShift, 0, alphabetSize, ->)), "Invalid characters in message."

runTests()
