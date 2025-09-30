import java.io.*;
import java.util.*;

// Enum para prioridade
enum Priority {
    ALTA, MEDIA, BAIXA;

    public static Priority fromString(String str) {
        return switch (str.toUpperCase()) {
            case "ALTA" -> ALTA;
            case "MEDIA" -> MEDIA;
            case "BAIXA" -> BAIXA;
            default -> null;
        };
    }
}

// Classe Item com categoria e prioridade
class Item implements Serializable {
    private final String name;
    private final int quantity;
    private final String category;
    private final Priority priority;

    public Item(String name, int quantity, String category, Priority priority) {
        this.name = name;
        this.quantity = Math.max(1, quantity);
        this.category = category;
        this.priority = priority;
    }

    public String getName() { return name; }
    public int getQuantity() { return quantity; }
    public String getCategory() { return category; }
    public Priority getPriority() { return priority; }

    @Override
    public String toString() {
        return name + " (x" + quantity + ") - Categoria: " + category + " - Prioridade: " + priority;
    }
}

// Classe ShoppingList
class ShoppingList implements Serializable {
    private final List<Item> items = new ArrayList<>();
    private static final String FILE_NAME = "shopping_list.txt";

    // Adiciona ou atualiza quantidade se já existir o mesmo nome + categoria
    public void addItem(Item newItem) {
        for (Item item : items) {
            if (item.getName().equalsIgnoreCase(newItem.getName())
                && item.getCategory().equalsIgnoreCase(newItem.getCategory())) {
                int updatedQty = item.getQuantity() + newItem.getQuantity();
                items.set(items.indexOf(item), new Item(item.getName(), updatedQty, item.getCategory(), item.getPriority()));
                System.out.println("Quantidade atualizada: " + item.getName() + " (x" + updatedQty + ")");
                saveToFile();
                return;
            }
        }
        items.add(newItem);
        System.out.println("Item adicionado: " + newItem);
        saveToFile();
    }

    public void listItems() {
        if (items.isEmpty()) {
            System.out.println("A lista está vazia.");
            return;
        }

        // Ordena por categoria e prioridade
        items.sort(Comparator.comparing(Item::getCategory)
                             .thenComparing(Item::getPriority));
        System.out.println("Itens da lista:");
        for (Item item : items) {
            System.out.println(" - " + item);
        }
    }

    public void removeItem(String name, String category) {
        Iterator<Item> it = items.iterator();
        boolean removed = false;
        while (it.hasNext()) {
            Item item = it.next();
            if (item.getName().equalsIgnoreCase(name) && item.getCategory().equalsIgnoreCase(category)) {
                it.remove();
                removed = true;
                System.out.println("Removido: " + item);
                saveToFile();
                break;
            }
        }
        if (!removed) {
            System.out.println("Item não encontrado.");
        }
    }

    public int countItems() {
        return items.size();
    }

    public int totalQuantity() {
        return items.stream().mapToInt(Item::getQuantity).sum();
    }

    private void saveToFile() {
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(FILE_NAME))) {
            oos.writeObject(items);
        } catch (IOException e) {
            System.out.println("Erro ao salvar lista: " + e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    public void loadFromFile() {
        File file = new File(FILE_NAME);
        if (!file.exists()) return;

        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(FILE_NAME))) {
            List<Item> loadedItems = (List<Item>) ois.readObject();
            items.clear();
            items.addAll(loadedItems);
        } catch (IOException | ClassNotFoundException e) {
            System.out.println("Erro ao carregar lista: " + e.getMessage());
        }
    }
}

// Classe abstrata Task
abstract class Task {
    private final String name;
    public Task(String name) { this.name = name; }
    public String getName() { return name; }
    public abstract void execute();
}

// PrintTask
class PrintTask extends Task {
    private final String message;
    public PrintTask(String name, String message) { super(name); this.message = message; }
    @Override
    public void execute() { System.out.println("[Tarefa: " + getName() + "] " + message); }
}

// Classe principal
public class Main {
    private static final Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {
        ShoppingList shoppingList = new ShoppingList();
        shoppingList.loadFromFile();

        new PrintTask("BoasVindas", "Bem-vindo ao sistema de Lista de Compras Avançada!").execute();
        new PrintTask("Info", "Adicione itens com categoria e prioridade, e visualize a lista ordenada.").execute();

        boolean running = true;
        while (running) {
            System.out.println("\n--- MENU ---");
            System.out.println("1 - Adicionar item");
            System.out.println("2 - Listar itens");
            System.out.println("3 - Remover item");
            System.out.println("4 - Contar itens");
            System.out.println("5 - Quantidade total de produtos");
            System.out.println("0 - Sair");
            System.out.print("Escolha: ");

            int option;
            try { option = Integer.parseInt(scanner.nextLine()); } 
            catch (NumberFormatException e) { System.out.println("Opção inválida."); continue; }

            switch (option) {
                case 1 -> addItem(shoppingList);
                case 2 -> shoppingList.listItems();
                case 3 -> removeItem(shoppingList);
                case 4 -> System.out.println("Total de itens: " + shoppingList.countItems());
                case 5 -> System.out.println("Quantidade total de produtos: " + shoppingList.totalQuantity());
                case 0 -> {
                    System.out.println("Encerrando o programa...");
                    running = false;
                }
                default -> System.out.println("Opção inválida.");
            }
        }

        System.out.println("Obrigado por usar o sistema!");
        scanner.close();
    }

    private static void addItem(ShoppingList shoppingList) {
        String name;
        do {
            System.out.print("Nome do item: ");
            name = scanner.nextLine().trim();
            if (name.isEmpty()) System.out.println("Nome não pode ser vazio.");
        } while (name.isEmpty());

        System.out.print("Categoria do item: ");
        String category = scanner.nextLine().trim();
        if (category.isEmpty()) category = "Geral";

        int qty;
        do {
            System.out.print("Quantidade: ");
            try {
                qty = Integer.parseInt(scanner.nextLine());
                if (qty <= 0) System.out.println("Quantidade deve ser maior que zero.");
            } catch (NumberFormatException e) { qty = -1; System.out.println("Digite um número válido."); }
        } while (qty <= 0);

        Priority priority;
        do {
            System.out.print("Prioridade (Alta, Media, Baixa): ");
            String p = scanner.nextLine().trim();
            priority = Priority.fromString(p);
            if (priority == null) System.out.println("Digite uma prioridade válida.");
        } while (priority == null);

        shoppingList.addItem(new Item(name, qty, category, priority));
    }

    private static void removeItem(ShoppingList shoppingList) {
        System.out.print("Nome do item a remover: ");
        String name = scanner.nextLine().trim();
        System.out.print("Categoria do item: ");
        String category = scanner.nextLine().trim();
        if (!name.isEmpty() && !category.isEmpty()) {
            shoppingList.removeItem(name, category);
        } else {
            System.out.println("Nome e categoria são obrigatórios.");
        }
    }
}
