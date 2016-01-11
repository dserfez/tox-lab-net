#!/bin/bash

#  - path: /opt/bin/start_lab.sh
#    permissions: "0755"
#    owner: root
#    content: |
#      #!/bin/bash
echo "  - path: /opt/bin/${1}"
echo '    permissions: "0755"'
echo '    owner: root'
echo '    content: |'
sed 's|^|      |' ${1}
