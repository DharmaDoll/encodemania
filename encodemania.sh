#! /bin/bash -eu

# Inspiration from CyberChef

# $ cp encodemania.sh ~/go/bin/encmania;  source ~/.zshrc
# Requirements
    # nkf
    # gnu sed

function usage() {
    SCRIPT=$(basename $0)
    
echo """
Usage:
    $ $SCRIPT <-m, -d, -e, -u> {payload}
    $ echo {payload} | $SCRIPT <-m, -d, -e, -u>
    $ echo /cgi-bin/%2e%2e/%2e%2e/etc/passwd | $SCRIPT -d -m url | xargs $SCRIPT -e -m url

Example:
  ALL              $SCRIPT あいうpayload
  Url Decode       $SCRIPT -d -m url /cgi-bin/%2e%2e/%2e%2e/etc/passwd 
  Url Encode       $SCRIPT -e -m url cgi-bin/../../../../etc/passwd
  Unicode point    $SCRIPT -u abcあいう_✌️_🏧  -> 61 62 63 3042 3044 3046 5f 270c fe0f 5f 1f3e7
  Escape Unicode   $SCRIPT -e -m unicode あいう
  Unscape Unicode  $SCRIPT -d -m unicode '\u30DD\u30DB\u3046\u270b\u309A'
  Hex              $SCRIPT -m hex <payload>
  Octal            $SCRIPT -m oct <payload>
  Binary           $SCRIPT -m bin <payload>
  HTML Entity      $SCRIPT -m html 'abc_あいう_!\"#$%&<>xx'\''yy'
  Quoted printable $SCRIPT -q hello_あいう_123
  Change IP format(decimal) 
                    $SCRIPT -c 127.0.0.1
  PEM to HEX       Please this great command! 'openssl rsa -in test.pem -out test.der -outform der'
  Hex to PEM       Please this great command! 'openssl rsa -in test.der -inform der > test.pem'
  To Hex Content   Not yet implementation
  Nomalise Unicode Not yet implementation
  Text Encoding Brute Force 
                    Please refer to nkf, iconv man pages.
  echo 'Paul and Carl' | sha1sum | cut -c2,4,11,16 未実施だよ
"""
}


if [[ -p /dev/stdin ]]; then
  while read stdin; do PAYLOAD="$stdin"; done
else
  if [[ "$#" -eq 0 ]]; then usage; exit 0; fi
  PAYLOAD=${@: -1}
fi

# echo payload: " $PAYLOAD"



# URL Encode
encode_url() {
  # $ echo curl http://\<host\>:\<Port\>/cgi-bin/../../../../etc/passwd| nkf -WwMQ | sed 's/=$//g' |tr = %|tr -d '\n'
  echo -n $PAYLOAD | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'
}

# URL Docode
decode_url() {
  # $ echo /cgi-bin/%%32%65%%32%65/%%32%65%%32%65/%%32%65%%32%65/%%32%65%%32%65/etc/passwd | nkf -wW --url-input
  echo -n $PAYLOAD | nkf -wW --url-input
}

hex() {
  echo -n $PAYLOAD|xxd -p -c256
}

bin() {
  echo -en "$PAYLOAD" | xxd -b | cut -c 11-63
}

oct() {
  # echo -en $PAYLOAD | od -An -to1 -w 256
  echo -en $PAYLOAD | hexdump -v -e '1/1 "%o "'
}

# Escape Unicode Characters
escape_unicode_point() {
  echo -en $PAYLOAD | nkf -W -w32B0 | xxd -ps -c4 | sed 's/^0*//' | sed 's/^/\\u/g' | tr -d '\n'
}

# To Charcode(unicode code point)
unicode_point() {
# To Charcode(unicode code point) -WオプションはinputをUTF-8とみなす。-w32B0 はUTF-32に変換(BOM無し・ビッグエンディアン) 。echo -e はエスケープもしを有効化する
  echo -en $PAYLOAD | nkf -W -w32B0 | xxd -ps -c4 | sed 's/^0*//' | tr '\n' ' '
}

# Unescape Unicode Characters
unescape_unicode_point() {
  # $./encodemania.sh '\u30DD\u30DB\u3046\u270b\u309A'
  # echo -e $PAYLOAD
  python -c "print('$PAYLOAD')"
}

# To HTML Entity ５種類のみ
html_entity() {
  # $ echo 'abc'\''def'   シングルクォートの中にシングルクォートを入れるやり方
  # abc'def
  echo -en "$PAYLOAD" | nkf -Z3
}

# Change IP format(Decimal)
change_ip() {
  echo -en $PAYLOAD | awk -F'.' '{print $1*256**3+$2*256**2+$3*256+$4}'
}

# Quoted Printable
quoted_printable() {
  echo -en $PAYLOAD | nkf -MQW
}


encode_flag=false
decode_flag=false
url_flag=false
unicode_flag=false

while getopts educqm:h OPT; do
    case "$OPT" in
        e )
          encode_flag=true
          ;;
        d )
          decode_flag=true
          ;;
        u )
          unicode_point; exit 0 ;;
        c )
          change_ip; exit 0;;
        q )
          quoted_printable; exit 0;;
        m )
            case "$OPTARG" in
                url)
                    url_flag=true ;;
                unicode)
                    unicode_flag=true ;;
                hex)
                    hex; exit 0 ;;
                oct)
                    oct; exit 0 ;;                    
                bin)
                    bin; exit 0 ;;
                html)
                    html_entity; exit 0 ;;
                * ) 
                    echo Undifined mode; exit 0;;
            esac
            ;;
        h )
            usage; exit 0 ;;
        * )
            usage; exit 0 ;;
        # \?) echo "[ERROR] Undefined command."
        #     _disp_help
        #     exit 0
    esac
done


if $encode_flag && $url_flag
then
  encode_url
  exit
fi

if $decode_flag && $url_flag
then
  decode_url
  exit
fi

if $encode_flag && $unicode_flag
then
  escape_unicode_point
  exit
fi

if $decode_flag && $unicode_flag
then
  unescape_unicode_point
  exit
fi




### Displayed ALL ###
echo -n '*** url_encode ***: '
encode_url
echo -e '\n'

echo -n '*** url_decode ***: '
decode_url
echo -e '\n'


echo -n '*** Unicode_code_point ***: '
unicode_point
echo -e '\n'

echo -n '*** Escape Unicode_code_point ***: '
escape_unicode_point
echo -e '\n'

echo -n '*** Unescape Unicode_code_point ***: '
unescape_unicode_point
echo -e '\n'

# Nomalise Unicode
echo -n '*** Nomalise Unicode ***: ' 'Not yet implementation'
echo ''

echo -n '*** Quoted printable ***: '
quoted_printable
echo -e '\n'


# PEM to HEX
echo -n '*** PEM to HEX ***: '
echo -en 'Please this great command! ' \''openssl rsa -in test.pem -out test.der -outform der'\'
echo -e '\n'

# Hex to PEM
echo -n '*** Hex to PEM ***: '
echo -en 'Please this great command! ' \''openssl rsa -in test.der -inform der'\'
echo -e '\n'

echo -n '*** Change IP format ***: '
change_ip
echo -e '\n'

# Text Encoding Brute Force
echo -n '*** Text Encoding Brute Force ***: '
echo -n ' Please refer to nkf, iconv man pages.'
echo ''

# To Hex Content
echo -n '*** To Hex Content ***: ' 'Not yet implementation'
echo ''

echo -n '*** hex ***: '
hex
echo -e '\n'

echo -n '*** Binary ***: '
bin
echo -e '\n'

echo -n '*** Octal ***: '
oct
echo -e '\n'

echo -n '*** HTML Entity ***: '
html_entity
echo -e '\n'

echo -n sha1sum 未だ実装してないよ
echo 'Paul and Carl' | sha1sum | cut -c2,4,11,16
