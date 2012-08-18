#!/bin/sh
MYSQL_PARAMETERS="$@"

if [ -z "$MYSQL_PARAMETERS" ]; then
	cat <<EOF
Syntax:
	$0 -uUSERNAME -pPASSWORD DATABASE
EOF
	exit 1
fi

db()
{
	/usr/bin/mysql $@ $MYSQL_PARAMETERS
}

run()
{
  _REGEXP="$1"
  _COMMENT="$2"
  grep -E "$_REGEXP" /var/log/mail.log |sed 's/.*\[\([^]]*\)\].*/insert into whitelist values ("\1", "'"$_COMMENT"'");/'|sort -u | db --force 2>&1 | grep -v "Duplicate entry"
}

count()
{
	echo "select count(*) from whitelist" | db --skip-column-names 
}

before=`count`

run '\.youtube\.com\[' "Youtube"
run '\.google\.com\[' "Gmail"
run '\.tfbnw\.net\[' "Facebook"
run '\.facebook\.com\[' "Facebook"
run '\.pixmania\.com\[' "Pixmania"
run '\.yahoo\.com\[' "Yahoo"
run '\.obsmtp\.com\[' "Postini"
run '\.twitter\.com\[' "Twitter"

after=`count`

echo "Added `expr $after - $before` hosts to whitelist."
