# 🧠 IntegraMente

**Aplicativo educacional inovador para Cálculo Integral**

[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-02569B?logo=flutter)](https://flutter.dev)
[![Web](https://img.shields.io/badge/Platform-Web-blue)](https://integramente-c1a64.web.app)
[![Firebase](https://img.shields.io/badge/Hosting-Firebase-orange?logo=firebase)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🚀 **Deploy Ativo**

**🌐 Acesse agora: [https://integramente-c1a64.web.app](https://integramente-c1a64.web.app)**

---

## 📖 **Sobre o Projeto**

O **IntegraMente** é uma aplicação web desenvolvida em Flutter que revoluciona o aprendizado de Cálculo Integral. Combinando matemática avançada com tecnologia moderna, oferece uma experiência interativa e intuitiva para estudantes e professores.

### 🎯 **Objetivo**
Facilitar o entendimento de conceitos complexos de Cálculo II através de:
- Visualizações gráficas interativas
- Cálculos simbólicos precisos  
- Interface responsiva e moderna
- Feedback educacional em tempo real

---

## ✨ **Funcionalidades Principais**

### 🔢 **Calculadora Avançada**
- **Integrais definidas e indefinidas**
- **Derivadas de funções complexas**
- **Cálculo simbólico com LaTeX**
- **Validação matemática em tempo real**

### 📊 **Visualização Gráfica**
- **Área sob curvas interativas**
- **Gráficos responsivos e dinâmicos**
- **Zoom e navegação fluidos**
- **Múltiplas resoluções de renderização**

### 📚 **Sistema de Histórico**
- **Persistência local de cálculos**
- **Organização por tipo e data**
- **Busca e filtros avançados**
- **Exportação de resultados**

### ⚙️ **Configurações Personalizáveis**
- **Temas e preferências visuais**
- **Formatos numéricos customizáveis**
- **Intervalos padrão configuráveis**
- **Performance otimizada**

### 🎓 **Tutorial Interativo**
- **Guias passo-a-passo**
- **Exemplos práticos integrados**
- **Conceitos fundamentais explicados**
- **Progressão estruturada de aprendizado**

---

## 🛠️ **Tecnologias Utilizadas**

### **Frontend**
- **Flutter 3.29.2** - Framework multiplataforma
- **Dart** - Linguagem de programação
- **Go Router** - Navegação declarativa
- **GetX** - Gerenciamento de estado
- **FL Chart** - Gráficos interativos
- **Flutter Math Fork** - Renderização LaTeX

### **Arquitetura**
- **Clean Architecture** - Separação clara de responsabilidades
- **MVVM Pattern** - Model-View-ViewModel
- **Responsive Design** - Adaptável a todos os dispositivos
- **Performance Optimization** - Lazy loading e cache inteligente

### **Hosting & Deploy**
- **Firebase Hosting** - CDN global + HTTPS
- **GitHub Actions** - CI/CD automatizado
- **Web Assembly** - Performance nativa no browser

---

## 📱 **Design Responsivo**

### **Breakpoints Inteligentes**
- **📱 Mobile:** `< 600px` - Interface compacta e touch-friendly
- **📟 Tablet:** `600px - 1024px` - Layout balanceado
- **🖥️ Desktop:** `> 1024px` - Experiência completa

### **Componentes Adaptativos**
- **SideMenu/Drawer** automático
- **Grid responsivo** (1-3 colunas)
- **Tipografia escalável**
- **Touch gestures** otimizados

---

## 🏗️ **Estrutura do Projeto**

```
lib/
├── core/                          # Configurações centrais
│   ├── config/                    # Configurações de backend
│   ├── constants/                 # Constantes e cores
│   ├── router/                    # Navegação (GoRouter)
│   ├── theme/                     # Temas e estilos
│   ├── utils/                     # Utilitários e helpers
│   └── performance/               # Otimizações de performance
├── data/                          # Camada de dados
│   ├── models/                    # Modelos de dados
│   ├── repositories/              # Repositórios
│   └── services/                  # Serviços (API, Storage)
├── presentation/                  # Interface do usuário
│   ├── controllers/               # Controladores GetX
│   ├── screens/                   # Telas principais
│   ├── widgets/                   # Componentes reutilizáveis
│   └── shared/                    # Widgets compartilhados
└── main.dart                      # Ponto de entrada
```

---

## 🚀 **Como Executar**

### **Pré-requisitos**
```bash
Flutter SDK >= 3.29.0
Dart SDK >= 3.7.2
Chrome/Edge para web
```

### **Instalação**
```bash
# Clone o repositório
git clone https://github.com/peSuperSam/integramente-front.git

# Acesse o diretório
cd integramente-front

# Instale as dependências
flutter pub get

# Execute em modo debug
flutter run -d chrome

# Ou build para produção
flutter build web --release
```

### **Configuração Backend**
Para funcionalidade completa, configure o backend Python:
```bash
# Clone o backend (repositório separado)
git clone https://github.com/seu-usuario/integramente-backend.git

# Configure as variáveis de ambiente no frontend
# Edite: lib/core/config/backend_config.dart
```

---

## 📊 **Performance & Otimizações**

### **Métricas Atuais**
- ⚡ **First Paint:** < 1.2s
- 🚀 **Interactive:** < 2.5s  
- 📦 **Bundle Size:** ~2.8MB (gzipped)
- 🎯 **Lighthouse Score:** 95+

### **Otimizações Implementadas**
- **Tree Shaking** - Remoção de código não utilizado
- **Lazy Loading** - Carregamento sob demanda
- **Object Pooling** - Reutilização de objetos
- **Smart Caching** - Cache inteligente de recursos
- **Async Processing** - Operações não-bloqueantes

---

## 🧪 **Testes**

```bash
# Testes unitários
flutter test

# Testes de widgets
flutter test test/widget_test.dart

# Testes de conectividade
flutter test test/backend_connectivity_test.dart

# Coverage report
flutter test --coverage
```

---

## 🔄 **CI/CD & Deploy**

### **Firebase Hosting**
```bash
# Deploy manual
firebase deploy --only hosting

# Deploy automático via GitHub Actions
# Configurado para deploy em push na branch main
```

### **Ambientes**
- **🚀 Production:** [integramente-c1a64.web.app](https://integramente-c1a64.web.app)
- **🧪 Staging:** Configurável via Firebase
- **💻 Local:** `flutter run -d chrome`

---

## 📄 **Licença**

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 👥 **Contribuição**

Contribuições são sempre bem-vindas! Para contribuir:

1. **Fork** o projeto
2. Crie uma **branch** para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add: AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. Abra um **Pull Request**

---

## 📞 **Contato & Suporte**

- **Desenvolvedor:** peSuperSam
- **Email:** [seu-email@exemplo.com]
- **GitHub:** [@peSuperSam](https://github.com/peSuperSam)
- **Issues:** [Reportar Bug](https://github.com/peSuperSam/integramente-front/issues)

---

## 🙏 **Agradecimentos**

- **Flutter Team** - Framework excepcional
- **Firebase** - Hosting confiável
- **Comunidade Open Source** - Packages incríveis
- **Estudantes de Cálculo** - Inspiração e feedback

---

<div align="center">

**📚 Feito com ❤️ para estudantes de Cálculo Integral**

[🌐 Demo](https://integramente-c1a64.web.app) • [📖 Docs](https://github.com/peSuperSam/integramente-front/wiki) • [🐛 Issues](https://github.com/peSuperSam/integramente-front/issues)

</div>
