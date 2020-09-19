function get_source() 
{
  # 0->last, priority low->high
  config_file=('third_dependences.conf' 'mt_dependences.conf')
  
  function filter() 
  {
    fgrep $1 $2 | awk -F',' '{print $2}'
  }
  
  ret=''
  for config in ${config_file[*]}
  do
    tmp=`filter $1 $config`
    if [ ! -z "$tmp" ]
    then
      ret=$tmp
    fi
  done
  export source_addr=$ret
}
