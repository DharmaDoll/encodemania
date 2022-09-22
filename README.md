# encodemania

Inspiration from CyberChef.

### Requirements
- nkf
- gnu sed

### Install
```sh
$ cp -a encodemania.sh ~/path/to/bin/encmania
$ export PATH="$PATH:~/path/to/bin/encmania"
$ source ~/.zshrc

```

### Usage
```sh
$ encmania

Usage:
    $ encmania <-m, -d, -e, -u> {payload}
    $ echo {payload} | encmania <-m, -d, -e, -u>
    $ echo /cgi-bin/%2e%2e/%2e%2e/etc/passwd | encmania -d -m url | xargs encmania -e -m url

Example:
  ALL              encmania あいうpayload
  Url Decode       encmania -d -m url /cgi-bin/%2e%2e/%2e%2e/etc/passwd
  Url Encode       encmania -e -m url cgi-bin/../../../../etc/passwd
  Unicode point    encmania -u abcあいう_✌️_🏧  -> 61 62 63 3042 3044 3046 5f 270c fe0f 5f 1f3e7
  Escape Unicode   encmania -e -m unicode あいう
  Unscape Unicode  encmania -d -m unicode '\u30DD\u30DB\u3046\u270b\u309A'
  Hex              encmania -m hex <payload>
  Octal            encmania -m oct <payload>
  Binary           encmania -m bin <payload>
  HTML Entity      encmania -m html 'abc_あいう_!"#$%&<>xx'\''yy'
  Quoted printable encmania -q hello_あいう_123
  Change IP format(decimal)
                    encmania -c 127.0.0.1
  PEM to HEX       Please this great command! 'openssl rsa -in test.pem -out test.der -outform der'
  Hex to PEM       Please this great command! 'openssl rsa -in test.der -inform der > test.pem'
  To Hex Content   Not yet implementation
  Nomalise Unicode Not yet implementation
  Text Encoding Brute Force
                    Please refer to nkf, iconv man pages.
  echo 'Paul and Carl' | sha1sum | cut -c2,4,11,16 未実施だよ
  ```
