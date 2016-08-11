/**
 * Copyright (C) 2016 Regents of the University of California.
 * @author: Jeff Thompson <jefft0@remap.ucla.edu>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * A copy of the GNU Lesser General Public License is in the file COPYING.
 */

function dump(message) { print(message); print("\n"); }

/**
 * Loop to encode a data packet nIterations times.
 * @param {integer} nIterations The number of iterations.
 * @param {bool} useComplex If true, use a large name, large content and all
 * fields. If false, use a small name, small content and only required fields.
 * @param {bool} useCrypto If true, sign the data packet. If false, use a blank
 * signature.
 * @return {table} A table with the fields (duration, encoding) where duration
 * is the number of seconds for all iterations and encoding is the wire encoding
 * Buffer.
 */
function benchmarkEncodeDataSeconds(nIterations, useComplex, useCrypto)
{
  local name;
  local content;
  if (useComplex) {
    // Use a large name and content.
    name = Name
      ("/ndn/ucla.edu/apps/lwndn-test/numbers.txt/%FD%05%05%E8%0C%CE%1D/%00");

    local contentString = "";
    local count = 1;
    contentString += "" + (count++);
    while (contentString.length < 1115)
      contentString += " " + (count++);
    content = Blob(contentString);
  }
  else {
    // Use a small name and content.
    name = Name("/test");
    content = Blob("abc");
  }
  local finalBlockId = NameComponent("\0");

  // Initialize the KeyChain storage in case useCrypto is true.

  local keyName = Name("/testname/DSK-123");
  local certificateName = keyName.getSubName(0, keyName.size() - 1)
    .append("KEY").append(keyName.get(keyName.size() - 1)).append("ID-CERT")
    .append("0");

  //generate KeyChain
  local identityStorage = MemoryIdentityStorage();
  local privateKeyStorage = MemoryPrivateKeyStorage();
  local keyChain = KeyChain
    (IdentityManager(identityStorage, privateKeyStorage),
     SelfVerifyPolicyManager(identityStorage));
  identityStorage.addKey(keyName, KeyType.RSA, Blob(DEFAULT_RSA_PUBLIC_KEY_DER, false));
  privateKeyStorage.setKeyPairForKeyName
    (keyName, KeyType.RSA, DEFAULT_RSA_PUBLIC_KEY_DER, DEFAULT_RSA_PRIVATE_KEY_DER);

  local signatureBits = blob(256);
  for (local i = 0; i < signatureBits.len(); ++i)
    signatureBits[i] = 0;

  local encoding = null;
  local start = getNowSeconds();
  for (local i = 0; i < nIterations; ++i) {
    local data = Data(name);
    data.setContent(content);
    if (useComplex) {
      data.getMetaInfo().setFreshnessPeriod(1000.0);
      data.getMetaInfo().setFinalBlockId(finalBlockId);
    }

    if (useCrypto)
      // This sets the signature fields.
      keyChain.sign(data, certificateName);
    else {
      // Imitate IdentityManager.signByCertificate to set up the signature
      // fields, but don't sign.
      local keyLocator = KeyLocator();
      keyLocator.setType(KeyLocatorType.KEYNAME);
      keyLocator.setKeyName(certificateName);
      local sha256Signature = data.getSignature();
      sha256Signature.setKeyLocator(keyLocator);
      sha256Signature.setSignature(signatureBits);
    }

// debug    encoding = data.wireEncode();
    encoding = Tlv0_2WireFormat.encodeData(data).encoding;
  }
  local finish = getNowSeconds();

  return { duration = finish - start, encoding = encoding };
}

function nameToUri(name) {
  if (name.size() == 0)
    return "/";

  local result = "";
  for (local i = 0; i < name.size(); ++i)
    result += "/" + name.get(i).getValue().toRawStr();

  return result;
}

local result = benchmarkEncodeDataSeconds(1, false, false);