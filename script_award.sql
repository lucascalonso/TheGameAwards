--  ./sqlite3 award.db < script_award.sql

CREATE TABLE user(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    password VARCHAR NOT NULL,
    role INTEGER NOT NULL
);

INSERT INTO user(name, email, password, role) VALUES('Teste 1', 'teste1@teste', '123456', 0);
INSERT INTO user(name, email, password, role) VALUES('Teste 2', 'teste2@teste', '123456', 0);
INSERT INTO user(name, email, password, role) VALUES('Teste 3', 'teste3@teste', '123456', 0);
INSERT INTO user(name, email, password, role) VALUES('Teste 4', 'teste4@teste', '123456', 1);
INSERT INTO user(name, email, password, role) VALUES('Teste 5', 'teste5@teste', '123456', 1);

CREATE TABLE genre(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL
);

INSERT INTO genre(name) VALUES('Aventura');
INSERT INTO genre(name) VALUES('Ação');
INSERT INTO genre(name) VALUES('RPG');
INSERT INTO genre(name) VALUES('Indie');
INSERT INTO genre(name) VALUES('Plataforma');
INSERT INTO genre(name) VALUES('Metroidvania');
INSERT INTO genre(name) VALUES('Rogue Lite');
INSERT INTO genre(name) VALUES('Survival Horror');
INSERT INTO genre(name) VALUES('Mundo Aberto');

CREATE TABLE game(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name VARCHAR NOT NULL UNIQUE,
    description TEXT NOT NULL,
    release_date VARCHAR NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(id)
);

INSERT INTO game(user_id, name, description, release_date) VALUES(1, 'Clair Obscur: Expedition 33', 'Once a year, the Paintress wakes and paints upon her monolith. Paints her cursed number. And everyone past that age turns to smoke and fades away. Year by year, that number ticks down and more of us are erased. Tomorrow she’ll wake and paint “33.” And tomorrow we depart on our final mission - Destroy the Paintress, so she can never paint death again. We are Expedition 33.
Clair Obscur: Expedition 33 is a ground-breaking turn-based RPG with unique real-time mechanics, making battles more immersive and addictive than ever. Explore a fantasy world inspired by Belle Époque France in which you battle devastating enemies.', '2025-04-24');

INSERT INTO game(user_id, name, description, release_date) VALUES(1, 'Hades 2', 'The first-ever sequel from Supergiant Games builds on the best aspects of the original god-like rogue-like dungeon crawler in an all-new, action-packed, endlessly replayable experience rooted in the Underworld of Greek myth and its deep connections to the dawn of witchcraft.', '2025-09-25');

INSERT INTO game(user_id, name, description, release_date) VALUES(2, 'Hollow Knight: Silksong', 'As the lethal hunter Hornet, adventure through a kingdom ruled by silk and song! Captured and taken to this unfamiliar world, prepare to battle mighty foes and solve ancient mysteries as you ascend on a deadly pilgrimage to the kingdom’s peak.
Hollow Knight: Silksong is the epic sequel to Hollow Knight, the award winning action-adventure. Journey to all-new lands, discover new powers, battle vast hordes of bugs and beasts and uncover secrets tied to your nature and your past. ', '2025-09-04');

INSERT INTO game(user_id, name, description, release_date) VALUES(3, '
Death Stranding 2: On the Beach', 'Com companheiros ao seu lado, Sam inicia uma nova jornada para salvar a humanidade da extinção.
Junte-se a eles na travessia desse mundo problemático repleto de inimigos sobrenaturais, obstáculos e uma questão inquietante: deveríamos ter nos conectado?
Hideo Kojima, o lendário designer de jogos, muda o mundo mais uma vez.', '2025-06-26');

INSERT INTO game(user_id, name, description, release_date) VALUES(3, '
Donkey Kong Bananza', 'Donkey Kong Bananza é um jogo eletrônico de plataforma desenvolvido e publicado pela Nintendo para o Nintendo Switch 2. O jogador controla o gorila Donkey Kong, que se aventura no subsolo com a jovem Pauline para recuperar artefatos conhecido como Cristais de Banândio de um grupo de macacos vilões.', '2025-07-17');

INSERT INTO game(user_id, name, description, release_date) VALUES(3, '
Kingdom Come: Deliverance II', 'Kingdom Come: Deliverance II é um RPG de ação desenvolvido pela Warhorse Studios e publicado pela Deep Silver. Sequência de Kingdom Come: Deliverance, o jogo foi lançado para PlayStation 5, Windows e Xbox Series X/S no dia 4 de fevereiro de 2025', '2025-02-04');

CREATE TABLE game_genre(
    game_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    FOREIGN KEY(game_id) REFERENCES game(id),
    FOREIGN KEY(genre_id) REFERENCES genre(id)
);

INSERT INTO game_genre(game_id, genre_id) VALUES(1, 3);
INSERT INTO game_genre(game_id, genre_id) VALUES(2, 2);
INSERT INTO game_genre(game_id, genre_id) VALUES(2, 3);
INSERT INTO game_genre(game_id, genre_id) VALUES(2, 4);
INSERT INTO game_genre(game_id, genre_id) VALUES(3, 2);
INSERT INTO game_genre(game_id, genre_id) VALUES(3, 3);
INSERT INTO game_genre(game_id, genre_id) VALUES(3, 4);
INSERT INTO game_genre(game_id, genre_id) VALUES(4, 2);
INSERT INTO game_genre(game_id, genre_id) VALUES(5, 1);
INSERT INTO game_genre(game_id, genre_id) VALUES(5, 2);
INSERT INTO game_genre(game_id, genre_id) VALUES(6, 3);
INSERT INTO game_genre(game_id, genre_id) VALUES(6, 9);


CREATE TABLE category(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title VARCHAR NOT NULL,
    description TEXT,  
    date VARCHAR NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(id)
);

INSERT INTO category(title, description, date, user_id) VALUES('Game of the Year','Recognizing a game that delivers the absolute best experience across all creative and technical fields.', '2025-12-11', 0);
INSERT INTO category(title, description, date, user_id) VALUES('Best Narrative','For outstanding storytelling and narrative development in a game.', '2025-12-11', 0);
INSERT INTO category(title, description, date, user_id) VALUES('Best RPG','For the best game designed with rich player character customization and progression, including massively multiplayer experiences.', '2025-12-11', 0);
INSERT INTO category(title, description, date, user_id) VALUES('Best Family','For the best game appropriate for family play, irrespective of genre or platform.', '2025-12-11', 0);
INSERT INTO category(title, description, date, user_id) VALUES('Best Independent Game','For outstanding creative and technical achievement in a game made outside the traditional publisher system.', '2025-12-11', 1);
INSERT INTO category(title, description, date, user_id) VALUES('Best Fighting','For the best game designed primarily around head-to-head combat.', '2025-12-11', 1);


CREATE TABLE category_game(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    game_id INTEGER NOT NULL,
    FOREIGN KEY(category_id) REFERENCES category(id),
    FOREIGN KEY(game_id) REFERENCES game(id)
);

INSERT INTO category_game(category_id, game_id) VALUES(1, 1);
INSERT INTO category_game(category_id, game_id) VALUES(1, 2);
INSERT INTO category_game(category_id, game_id) VALUES(1, 3);
INSERT INTO category_game(category_id, game_id) VALUES(1, 4);
INSERT INTO category_game(category_id, game_id) VALUES(1, 5);
INSERT INTO category_game(category_id, game_id) VALUES(1, 6);
INSERT INTO category_game(category_id, game_id) VALUES(2, 1);
INSERT INTO category_game(category_id, game_id) VALUES(2, 2);

CREATE TABLE user_vote(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    vote_game_id INTEGER NOT NULL,    
    FOREIGN KEY(user_id) REFERENCES user(id),
    FOREIGN KEY(category_id) REFERENCES category(id),
    FOREIGN KEY(vote_game_id) REFERENCES category_game(game_id)
);

INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(4, 1, 3);
INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(4, 2, 1);
INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(4, 1, 3);
INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(5, 1, 1);
INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(5, 2, 2);


select user.id, user.name, game.name from game left join user on game.user_id = user.id;

select game.name, genre.name from game left join game_genre on game.id = game_genre.game_id left join genre on genre.id = game_genre.genre_id;

select category.title, game.name from category_game left join game on game.id = category_game.game_id left join category on category.id = category_game.category_id;

select category_game.id, category.title, game.name, COUNT(user_vote.vote_game_id) from user_vote left join category_game on category_game.id = user_vote.category_id inner join category on category.id = user_vote.category_id inner join game on game.id = user_vote.vote_game_id group by user_vote.category_id, user_vote.vote_game_id;

