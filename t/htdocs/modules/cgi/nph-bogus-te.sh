#!/bin/sh
echo HTTP/1.1 200 OK
echo Content-Type: text/plain
echo Transfer-Encoding: chunked
echo -e '\r'
echo -e '6\r'
echo -e 'hello\n\r'
echo -e '0\r'
echo -e '\r'
