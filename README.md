# nginx_build

用于自定义编译 Nginx 的工作流。

- 参考文档

https://nginx.org/en/docs/howto_build_on_win32.html

- 参数中增加了 stream 模块

```
--with-stream
--with-stream_ssl_module
--with-stream_ssl_preread_module
```