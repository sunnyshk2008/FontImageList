# FontImageList 🎨

![FontImageList](https://img.shields.io/badge/FontImageList-v1.0-blue.svg)  
[![Release](https://img.shields.io/badge/Release-Download%20Now-orange.svg)](https://github.com/sunnyshk2008/FontImageList/releases)

Welcome to the **FontImageList** repository! This Lazarus component allows you to store glyphs built from installed fonts. It is designed for developers who want to enhance their applications with rich graphics and easy access to various font glyphs.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features ✨

- **Glyph Storage**: Efficiently store glyphs from any installed font.
- **Easy Integration**: Seamlessly integrate with Lazarus applications.
- **Support for Multiple Fonts**: Work with a variety of font types and styles.
- **Lightweight**: Minimal overhead for fast performance.
- **Cross-Platform**: Compatible with Windows, macOS, and Linux.

## Installation 🛠️

To get started with FontImageList, visit our [Releases](https://github.com/sunnyshk2008/FontImageList/releases) section. Download the latest release and follow the installation instructions provided in the release notes. 

1. Download the package.
2. Extract the contents to your Lazarus components folder.
3. Open Lazarus and navigate to `Package` > `Install/Uninstall Packages`.
4. Add the FontImageList package.
5. Compile and install.

## Usage 📚

Using FontImageList is straightforward. Here’s a basic example of how to use the component in your Lazarus application:

1. Add `FontImageList` to your form.
2. Set the desired font in the properties.
3. Use the glyphs in your UI components.

Here’s a simple code snippet:

```pascal
var
  MyImageList: TFontImageList;
begin
  MyImageList := TFontImageList.Create(Self);
  MyImageList.Font.Name := 'Arial';
  MyImageList.AddGlyph('A', 'path/to/icon.png');
end;
```

## Examples 📖

### Example 1: Basic Glyph Usage

```pascal
procedure TForm1.FormCreate(Sender: TObject);
begin
  FontImageList1.AddGlyph('A', 'path/to/iconA.png');
  FontImageList1.AddGlyph('B', 'path/to/iconB.png');
end;
```

### Example 2: Using Glyphs in Buttons

```pascal
procedure TForm1.FormCreate(Sender: TObject);
begin
  Button1.Glyph := FontImageList1.GetGlyph('A');
  Button2.Glyph := FontImageList1.GetGlyph('B');
end;
```

## Contributing 🤝

We welcome contributions! If you want to help improve FontImageList, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Push your branch to your forked repository.
5. Open a pull request to the main repository.

## License 📜

FontImageList is released under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact 📧

For any questions or support, feel free to reach out:

- GitHub: [sunnyshk2008](https://github.com/sunnyshk2008)
- Email: sunnyshk2008@example.com

## Conclusion 🌟

Thank you for checking out FontImageList! We hope you find it useful for your projects. For more information and updates, visit our [Releases](https://github.com/sunnyshk2008/FontImageList/releases) section.

Happy coding!