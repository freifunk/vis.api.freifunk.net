import logging
import yaml
from scripts.insert_data import insert_data

# Logging-Konfiguration
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    # Konfiguration laden
    with open('config.yaml', 'r') as config_file:
        config = yaml.safe_load(config_file)

    # Logging-Level aus der Konfiguration setzen
    log_level = config['logging']['level'].upper()
    logging.getLogger().setLevel(log_level)

    # Starten des Einfügens der Daten
    insert_data(config)


if __name__ == "__main__":
    main()
