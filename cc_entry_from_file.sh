#!/bin/bash

#  - path: /opt/bin/start_lab.sh
#    permissions: "0755"
#    owner: root
#    content: |
#      #!/bin/bash
      
sed 's|^|      |' ${1}
