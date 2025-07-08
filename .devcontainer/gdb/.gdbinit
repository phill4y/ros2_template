# STL related
add-auto-load-safe-path /usr/lib64/libstdc++.so.6.0.32-gdb.py

# STL
python
import sys

sys.path.insert(0, '/usr/share/gcc/python')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers(None)

end

# eigen
python
import sys

sys.path.insert(0, '/opt/gdb')
from printers import register_eigen_printers
register_eigen_printers(None)

end

# TODO(phillip): Fix pretty printers for nlohmann_json -> .devcontainer/gdb/printers/nlohmann.py
# # nlohmann_json
# python
# import sys

# # sys.path.insert(0, '/opt/gdb')
# from printers import register_nlohmann_printers
# register_nlohmann_printers(None)

# end
