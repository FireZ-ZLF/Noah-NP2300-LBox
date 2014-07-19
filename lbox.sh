#! /bin/sh

#LBox for NP2300

LBOX=$(dirname $0)
cd $LBOX

msg="$LBOX/qmsgbox"
 
WORKPLACE="/tmp/LBox"
INSTINFO="$WORKPLACE/lbox.txt"
TMP_INSTLOG="$WORKPLACE/lbox_install.log"
DATA_INSTLOG="/opt/lbox/data/lbox_install.log"
DATA_RMSCR="/opt/lbox/data/lbox_rm"

rundir()
{
  for SCRIPT in $(ls $1)
  do
    $1/$SCRIPT
  done
}

running()
{
  case $running in
    '\') running='/' ; echo -en "\b$running" > /dev/tty0;;
    '/') running='-' ; echo -en "\b$running" > /dev/tty0;;
    '-') running='\' ; echo -en "\b$running" > /dev/tty0;;
    *) running='/' ; echo -en "\b$running" > /dev/tty0;;
  esac
}

showlog()
{
  iconv -f gb2312 -t utf-8 $INSTINFO > /tmp/LBox.html
  helpbrowser /tmp/LBox.html
  rm /tmp/LBox.html
}

title()
{
echo "----------"
echo $1
echo "----------"
}

install()
{
[ -d $WORKPLACE ]&&rm -rf $WORKPLACE
mkdir $WORKPLACE

#��װ��Ϣ
exec &> $INSTINFO
echo "LBox��װ��"

#tty0��װ����
sleep 1s
clear > /dev/tty0
echo -e "\n\n\n\n\n\n\n\n" > /dev/tty0

running

#����
if [ -f $DATA_INSTLOG ];then
  title "����..."
  #����ж�ؽű�
  rundir $DATA_RMSCR
  rm -rf $DATA_RMSCR
  running
  #ɾ�������ļ�
  for rf in $(cat $DATA_INSTLOG)
  do
    rfa=$(echo $rf|sed 's#/opt/lbox#lbox#g')
    rfb=$(echo $rf|sed 's#/opt/QtPalmtop#qpe#g')
    if [ ! -d $rf ];then
      [ -f ./${rfa} -o -f ./${rfb} ]||{ rm $rf ; echo "rm $rf" ;}
    else
      [ -d ./${rfa} -o -d ./${rfb} ]||{ rm -r $rf ; echo "rm $rf" ;}
    fi
    running
  done
  rm $DATA_INSTLOG
fi
echo -e "\b20% Done." > /dev/tty0

#��װ/�����ļ�
instdir()
{
[ ! -d $2 ]&&mkdir -p $2
for inst_file in $(ls $1)
do
  if [ -d $1/$inst_file ];then
    instdir "$1/$inst_file" "$2/$inst_file"
  else
    if [ ! -f $2/$inst_file ];then
      echo "Install $2/$inst_file"
      cp "$1/$inst_file" "$2/$inst_file"
    else
      if [ -n "$( diff -q "$1/$inst_file" "$2/$inst_file" )" ];then
        echo "Upgrade $2/$inst_file"
        cp  $1/$inst_file $2/$inst_file
      else
        echo "Skip $2/$inst_file"
      fi
    fi
    echo "$2/$inst_file" >> $TMP_INSTLOG
  fi
  running
done
echo "$2" >> $TMP_INSTLOG
}

title "Install/Upgrade(lbox)"
instdir lbox /opt/lbox

echo -e "\b40% Done." > /dev/tty0

cd qpe
for d in apps2 apps/5Tool bin data lib pics
do
  title "Install/Upgrade ${d}(qpe)"
  instdir $d /opt/QtPalmtop/$d
done
cd ..

echo -e "\b60% Done." > /dev/tty0

#���а�װ�ű�
rundir "script/install"
echo -e "\b80% Done." > /dev/tty0

#ж�ؽű� -> (DATA)
cp script/remove $DATA_RMSCR -R
#��װ��¼ -> (DATA)
mv $TMP_INSTLOG $DATA_INSTLOG
echo -e "\b100% Done." > /dev/tty0
sleep 1s
}

uninstall()
{
if [ ! -f $DATA_INSTLOG ];then
  $msg 13 "�˳�" "" "" 0 0 "LBox��װ��" "��δ��װLBox(>3.0)"
  exit
fi
[ -d $WORKPLACE ]&&rm -rf $WORKPLACE
mkdir $WORKPLACE

#ж����Ϣ
exec &> $INSTINFO
echo "LBox��װ��"

#tty0ж�ؽ���
sleep 1s
clear > /dev/tty0
echo -e "\n\n\n\n\n\n\n\n" > /dev/tty0

mv $DATA_INSTLOG $TMP_INSTLOG

###����ж�ؽű�(DATA)
rundir $DATA_RMSCR
###ɾ��ж�ؽű�(DATA)
rm -r $DATA_RMSCR

#ɾ���ļ�
for file in $(cat $TMP_INSTLOG)
do
  if [ -f $file ];then
    rm $file
    echo "Remove $file"
  elif [ -d $file ];then
    if [ ! -n "$(ls -A $file)" ];then
      rm -r $file
      echo "Rmdir $file"
    else
      echo "Skip $file (Ŀ¼�ǿ�)"
    fi
  else
    echo "Skip $file (�޴��ļ�)"
  fi
  running
done
rm $TMP_INSTLOG

echo -e "\bDone." > /dev/tty0
}


case $($msg 11 "��װ/����" "ж��" "" 0 -1 "LBox��װ����" "LBox��װ����") in
0) install ;;
1) uninstall ;;
*) exit ;;
esac

[ "$($msg 11 "��" "�˳�" "" 0 1 "LBox��װ����" "�Ƿ�鿴��װ/����/ж����־?")" = 0 ]&&showlog
rm -r $WORKPLACE