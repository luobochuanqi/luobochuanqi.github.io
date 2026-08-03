# 保留 Chirpy gem 主题，以 Sass 覆盖定制，不 fork

重构视觉层时，我们决定继续以 gem 方式引入 jekyll-theme-chirpy，通过 `_sass` 覆盖、自定义 layout 与静态资源注入实现皮肤与面板，而不是 fork 主题源码或迁移到 Astro/Next.js 等新栈。

理由：fork 会永久承担与上游同步的维护税，而本次重构的内容（文章、评论、归档、PWA）全部依赖 Chirpy 既有功能；换栈则要为纯视觉收益重做构建、部署与 permalink 兼容。gem + 覆盖保留了升级通道，代价是覆盖层需要对抗主题内部类名（必要时 `!important`），这是接受的代价。
