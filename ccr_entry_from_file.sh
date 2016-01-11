#!/bin/bash

#  - path: /opt/bin/start_lab.sh
#    permissions: "0755"
#    owner: root
#    content: |
#      #!/bin/bash
echo '- content: |'
sed 's|^|    |' ${1}
echo '  encoding:'
echo '  owner: root'
echo "  path: /opt/bin/${1}"
echo '  permissions: "0755"'
