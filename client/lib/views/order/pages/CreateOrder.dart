import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:damd_trabalho_1/components/Input.dart';
import 'package:damd_trabalho_1/components/Button.dart';
import 'package:damd_trabalho_1/components/AppBar.dart';
import 'package:damd_trabalho_1/components/Card.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/User.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:damd_trabalho_1/controllers/order.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  // Order basic info controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _discountController = TextEditingController();

  // Address controllers
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Order items
  List<OrderItem> _orderItems = [];
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Add listeners to update the UI when any field changes
    _nameController.addListener(() {
      setState(() {});
    });

    _descriptionController.addListener(() {
      setState(() {});
    });

    _deliveryFeeController.addListener(() {
      setState(() {});
    });

    _discountController.addListener(() {
      setState(() {});
    });

    _streetController.addListener(() {
      setState(() {});
    });

    _numberController.addListener(() {
      setState(() {});
    });

    _neighborhoodController.addListener(() {
      setState(() {});
    });

    _cityController.addListener(() {
      setState(() {});
    });

    _stateController.addListener(() {
      setState(() {});
    });

    _zipCodeController.addListener(() {
      setState(() {});
    });

    _streetController.addListener(() {
      setState(() {});
    });

    _numberController.addListener(() {
      setState(() {});
    });

    _neighborhoodController.addListener(() {
      setState(() {});
    });

    _cityController.addListener(() {
      setState(() {});
    });

    _stateController.addListener(() {
      setState(() {});
    });

    _zipCodeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _deliveryFeeController.dispose();
    _discountController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemQuantityController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  void _addOrderItem() {
    if (_itemNameController.text.isNotEmpty &&
        _itemPriceController.text.isNotEmpty &&
        _itemQuantityController.text.isNotEmpty) {
      final price = double.tryParse(_itemPriceController.text) ?? 0.0;
      final quantity = int.tryParse(_itemQuantityController.text) ?? 1;

      if (price > 0 && quantity > 0) {
        setState(() {
          _orderItems.add(
            OrderItem(
              name: _itemNameController.text,
              price: price,
              quantity: quantity,
              description: _itemDescriptionController.text,
            ),
          );
        });

        // Clear item form
        _itemNameController.clear();
        _itemPriceController.clear();
        _itemQuantityController.clear();
        _itemDescriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item adicionado ao pedido')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preço e quantidade devem ser maiores que zero'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome, preço e quantidade do item'),
        ),
      );
    }
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item removido do pedido')));
  }

  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null && userString.isNotEmpty) {
      try {
        return User.fromJson(jsonDecode(userString));
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _createOrder() async {
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item ao pedido')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      final address = Address(
        street: _streetController.text,
        number: _numberController.text,
        complement: _complementController.text,
        neighborhood: _neighborhoodController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
      );

      final order = Order(
        name: _nameController.text,
        description: _descriptionController.text,
        date: DateTime.now().toIso8601String(),
        time: DateTime.now().toIso8601String(),
        status: Status.pending,
        address: address,
        items: _orderItems,
        deliveryFee: double.tryParse(_deliveryFeeController.text) ?? 0.0,
        discount: double.tryParse(_discountController.text) ?? 0.0,
      );

      await OrderController.createOrder(order, user.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido criado com sucesso!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(item: 'orders'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar pedido: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _totalPrice {
    return _orderItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double get _finalTotal {
    final deliveryFee = double.tryParse(_deliveryFeeController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    return _totalPrice + deliveryFee - discount;
  }

  Widget _buildOrderInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInput(
            controller: _nameController,
            labelText: 'Nome do Restaurante/Loja',
            hintText: 'Ex: Restaurante do Sabor',
            type: InputType.text,
          ),
          const SizedBox(height: Tokens.spacing16),
          CustomInput(
            controller: _descriptionController,
            labelText: 'Descrição do Pedido',
            hintText: 'Ex: Prato do dia + sobremesa',
            type: InputType.text,
          ),
          const SizedBox(height: Tokens.spacing16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  controller: _deliveryFeeController,
                  labelText: 'Taxa de Entrega (R\$)',
                  hintText: '0.00',
                  type: InputType.number,
                  validator: (value) => null, // Optional field
                ),
              ),
              const SizedBox(width: Tokens.spacing16),
              Expanded(
                child: CustomInput(
                  controller: _discountController,
                  labelText: 'Desconto (R\$)',
                  hintText: '0.00',
                  type: InputType.number,
                  validator: (value) => null, // Optional field
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Padding(
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomInput(
                  controller: _streetController,
                  labelText: 'Rua',
                  hintText: 'Nome da rua',
                  type: InputType.text,
                ),
              ),
              const SizedBox(width: Tokens.spacing16),
              Expanded(
                child: CustomInput(
                  controller: _numberController,
                  labelText: 'Número',
                  hintText: '123',
                  type: InputType.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tokens.spacing16),
          CustomInput(
            controller: _complementController,
            labelText: 'Complemento (Opcional)',
            hintText: 'Apto, Bloco, etc.',
            type: InputType.text,
            validator: (value) => null, // Optional field
          ),
          const SizedBox(height: Tokens.spacing16),
          CustomInput(
            controller: _neighborhoodController,
            labelText: 'Bairro',
            hintText: 'Nome do bairro',
            type: InputType.text,
          ),
          const SizedBox(height: Tokens.spacing16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomInput(
                  controller: _cityController,
                  labelText: 'Cidade',
                  hintText: 'Nome da cidade',
                  type: InputType.text,
                ),
              ),
              const SizedBox(width: Tokens.spacing16),
              Expanded(
                child: CustomInput(
                  controller: _stateController,
                  labelText: 'Estado',
                  hintText: 'UF',
                  type: InputType.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tokens.spacing16),
          CustomInput(
            controller: _zipCodeController,
            labelText: 'CEP',
            hintText: '00000-000',
            type: InputType.text,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsStep() {
    return Padding(
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add item form
          CustomInput(
            controller: _itemNameController,
            labelText: 'Nome do Item',
            hintText: 'Ex: Hambúrguer',
            type: InputType.text,
            validator: (value) => null, // No validation for item form
          ),
          const SizedBox(height: Tokens.spacing16),
          CustomInput(
            controller: _itemDescriptionController,
            labelText: 'Descrição (Opcional)',
            hintText: 'Detalhes do item',
            type: InputType.text,
            validator: (value) => null, // Optional field
          ),
          const SizedBox(height: Tokens.spacing16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  controller: _itemPriceController,
                  labelText: 'Preço (R\$)',
                  hintText: '0.00',
                  type: InputType.number,
                  validator: (value) => null, // No validation for item form
                ),
              ),
              const SizedBox(width: Tokens.spacing16),
              Expanded(
                child: CustomInput(
                  controller: _itemQuantityController,
                  labelText: 'Quantidade',
                  hintText: '1',
                  type: InputType.number,
                  validator: (value) => null, // No validation for item form
                ),
              ),
            ],
          ),
          const SizedBox(height: Tokens.spacing16),
          Button(
            text: 'Adicionar Item',
            onPressed: _addOrderItem,
            variant: ButtonVariant.outline,
          ),

          if (_orderItems.isNotEmpty) ...[
            const SizedBox(height: Tokens.spacing20),
            const Divider(),
            const SizedBox(height: Tokens.spacing16),
            Text(
              'Itens Adicionados',
              style: TextStyle(
                fontSize: Tokens.fontSize16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Tokens.spacing12),

            // List of added items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orderItems.length,
              separatorBuilder:
                  (context, index) => const SizedBox(height: Tokens.spacing8),
              itemBuilder: (context, index) {
                final item = _orderItems[index];
                return Container(
                  padding: const EdgeInsets.all(Tokens.spacing12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(Tokens.radius8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: Tokens.fontSize14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: Tokens.spacing4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: Tokens.fontSize12,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: Tokens.spacing4),
                            Text(
                              'R\$ ${item.price.toStringAsFixed(2)} x ${item.quantity}',
                              style: TextStyle(
                                fontSize: Tokens.fontSize12,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Tokens.fontSize14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: Tokens.spacing8),
                      IconButton(
                        onPressed: () => _removeOrderItem(index),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewStep() {
    return Padding(
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Info Summary
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Pedido',
                    style: TextStyle(
                      fontSize: Tokens.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Tokens.spacing8),
                  Text('${_nameController.text}'),
                  Text('${_descriptionController.text}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.spacing16),

          // Address Summary
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Endereço de Entrega',
                    style: TextStyle(
                      fontSize: Tokens.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Tokens.spacing8),
                  Text('${_streetController.text}, ${_numberController.text}'),
                  if (_complementController.text.isNotEmpty)
                    Text('${_complementController.text}'),
                  Text(
                    '${_neighborhoodController.text}, ${_cityController.text} - ${_stateController.text}',
                  ),
                  Text('CEP: ${_zipCodeController.text}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.spacing16),

          // Items and Total Summary
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do Pedido',
                    style: TextStyle(
                      fontSize: Tokens.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Tokens.spacing12),

                  // Items list
                  if (_orderItems.isNotEmpty) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _orderItems.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(height: Tokens.spacing8),
                      itemBuilder: (context, index) {
                        final item = _orderItems[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.name}',
                                style: TextStyle(
                                  fontSize: Tokens.fontSize14,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Tokens.fontSize14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: Tokens.spacing16),
                    const Divider(),
                    const SizedBox(height: Tokens.spacing12),
                  ],

                  // Order summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: TextStyle(
                          fontSize: Tokens.fontSize14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'R\$ ${_totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Tokens.fontSize14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Tokens.spacing8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taxa de Entrega:',
                        style: TextStyle(
                          fontSize: Tokens.fontSize14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'R\$ ${(double.tryParse(_deliveryFeeController.text) ?? 0.0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Tokens.fontSize14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if ((double.tryParse(_discountController.text) ?? 0.0) >
                      0) ...[
                    const SizedBox(height: Tokens.spacing8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Desconto:',
                          style: TextStyle(
                            fontSize: Tokens.fontSize14,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        Text(
                          '- R\$ ${(double.tryParse(_discountController.text) ?? 0.0).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: Tokens.fontSize14,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: Tokens.spacing8),
                  const Divider(),
                  const SizedBox(height: Tokens.spacing8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: Tokens.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'R\$ ${_finalTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Tokens.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0: // Order Info
        return _nameController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty;
      case 1: // Address
        return _streetController.text.isNotEmpty &&
            _numberController.text.isNotEmpty &&
            _neighborhoodController.text.isNotEmpty &&
            _cityController.text.isNotEmpty &&
            _stateController.text.isNotEmpty &&
            _zipCodeController.text.isNotEmpty;
      case 2: // Items
        return _orderItems.isNotEmpty;
      case 3: // Overview
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Criar Pedido'),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed:
                        _canContinue()
                            ? () {
                              setState(() {
                                _currentStep++;
                              });
                            }
                            : null,
                    child: const Text('Continuar'),
                  ),
                if (_currentStep == 3)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createOrder,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Criar Pedido'),
                  ),
                const SizedBox(width: Tokens.spacing8),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: const Text('Voltar'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Informações'),
              content: _buildOrderInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Endereço'),
              content: _buildAddressStep(),
              isActive: _currentStep >= 1,
              state:
                  _currentStep > 1
                      ? StepState.complete
                      : _currentStep == 1
                      ? StepState.indexed
                      : StepState.disabled,
            ),
            Step(
              title: const Text('Itens'),
              content: _buildItemsStep(),
              isActive: _currentStep >= 2,
              state:
                  _currentStep > 2
                      ? StepState.complete
                      : _currentStep == 2
                      ? StepState.indexed
                      : StepState.disabled,
            ),
            Step(
              title: const Text('Revisão'),
              content: _buildOverviewStep(),
              isActive: _currentStep >= 3,
              state: _currentStep == 3 ? StepState.indexed : StepState.disabled,
            ),
          ],
        ),
      ),
    );
  }
}
