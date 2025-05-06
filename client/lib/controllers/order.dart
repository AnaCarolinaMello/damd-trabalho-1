import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';

class OrderController {
  static List<Order> orders = [
    Order(
      id: '4752348',
      name: 'Restaurante Sabor Caseiro',
      description: 'Prato do dia + sobremesa',
      date: 'Hoje',
      time: '12:30',
      status: 'Em preparação',
      imageUrl: 'assets/images/restaurant1.png',
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',  
        state: 'SP',
        zipCode: '01310-100',
      ),
      deliveryFee: 5.0,
      discount: 2.0,
      items: [
        OrderItem(name: 'Prato do dia', price: 25.0, quantity: 1),
        OrderItem(name: 'Sovermesa', price: 12.90, quantity: 1),
      ],
    ),
    Order(
      id: '4752341',
      name: 'Supermercado Livre',
      description: '8 itens',
      date: 'Hoje',
      time: '10:45',
      status: 'Saiu para entrega',
      imageUrl: 'assets/images/market.png',
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [
        OrderItem(name: 'Arroz', price: 10.0, quantity: 2),
        OrderItem(name: 'Feijão', price: 8.0, quantity: 1),
      ],
    ),
    Order(
      id: '4751598',
      name: 'Farmácia Bem Estar',
      description: '3 itens',
      date: '12 Set',
      time: '16:20',
      status: 'Entregue',
      imageUrl: 'assets/images/pharmacy.png',
      isRated: true,
      rating: 4.0,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [
        OrderItem(name: 'Paracetamol', price: 10.0, quantity: 2),
        OrderItem(name: 'Ibuprofeno', price: 8.0, quantity: 1),
      ],
    ),
    Order(
      id: '4751256',
      name: 'Açaí do Nordeste',
      description: 'Açaí 500ml + Complementos',
      date: '10 Set',
      time: '19:15',
      status: 'Entregue',
      imageUrl: 'assets/images/acai.png',
      isRated: true,
      rating: 5.0,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [OrderItem(name: 'Açaí', price: 23.90, quantity: 1)],
    ),
    Order(
      id: '4750928',
      name: 'Hamburgueria Artesanal',
      description: 'Combo X-Tudo',
      date: '05 Set',
      time: '20:45',
      status: 'Entregue',
      imageUrl: 'assets/images/burger.png',
      isRated: true,
      rating: 3.5,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [OrderItem(name: 'Combo X-Tudo', price: 42.50, quantity: 1)],
    ),
    Order(
      id: '4750348',
      name: 'Pizza Express',
      description: 'Pizza Grande Marguerita',
      date: '02 Set',
      time: '21:10',
      status: 'Entregue',
      imageUrl: 'assets/images/pizza.png',
      isRated: true,
      rating: 4.5,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [
        OrderItem(name: 'Pizza Grande Marguerita', price: 49.90, quantity: 1),
      ],
    ),
  ];

  static Future<List<Order>> getOrders() async {
    return orders;
  }

  static Future<Order> getOrder(String id) async {
    return orders.firstWhere((order) => order.id == id);
  }
}
