enum MyEnum { one, two }

void main() {
  MyEnum value = MyEnum.one;
  String enumName = value.toString().split('.').first;
  print(enumName); // Output: MyEnum
}
